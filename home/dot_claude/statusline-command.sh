#!/usr/bin/env sh
input=$(cat)

# Without jq we can't parse the input, so render nothing
command -v jq >/dev/null 2>&1 || exit 0

# Single jq call; @sh quotes each value so eval is safe
eval "$(printf '%s' "$input" | jq -r '@sh "cwd=\(.cwd // .workspace.current_dir // "") model=\(.model.display_name // "") effort=\(.effort.level // "") tokens=\(.context_window.total_input_tokens // "") pct=\(.context_window.used_percentage // "")"')"

# Fall back to the env var if the JSON field is absent
[ -z "$effort" ] && effort="$CLAUDE_EFFORT"

# Directory: show basename unless it's home
home="$HOME"
if [ "$cwd" = "$home" ]; then
	dir="~"
else
	dir=$(basename "$cwd")
fi

# Build status line
parts=""

# Cyan for directory
[ -n "$dir" ] && parts=$(printf '\033[36m%s\033[0m' "$dir")

# Magenta for model
if [ -n "$model" ]; then
	[ -n "$parts" ] && parts="$parts  "
	parts="$parts$(printf '\033[35m%s\033[0m' "$model")"
	if [ -n "$effort" ]; then
		parts="$parts$(printf '\033[35m - %s\033[0m' "$effort")"
	fi
fi

# Context used: "200.0k (20.0%)" — shown only once usage has been reported
if [ -n "$pct" ]; then
	if [ "$tokens" -lt 999500 ]; then
		tenths=$(( (tokens + 50) / 100 ))
		tok="$((tenths / 10)).$((tenths % 10))k"
	else
		tenths=$(((tokens + 50000) / 100000))
		tok="$((tenths / 10)).$((tenths % 10))M"
	fi

	pct_fmt=$(awk -v p="$pct" 'BEGIN { printf "%.1f", p }')

	# Color by usage: <25% green, 25-75% yellow, >75% red
	pct_color=$(awk -v p="$pct" 'BEGIN { if (p < 25) print "32"; else if (p <= 75) print "33"; else print "31" }')

	[ -n "$parts" ] && parts="$parts  "
	parts="$parts$(printf '\033[%sm\033[1m%s\033[22m (%s%%)\033[0m' "$pct_color" "$tok" "$pct_fmt")"
fi

printf '%s' "$parts"
