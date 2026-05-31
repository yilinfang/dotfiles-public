#!/usr/bin/env sh
input=$(cat)

# Without jq we can't parse the input, so render nothing
command -v jq >/dev/null 2>&1 || exit 0

cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
effort=$(echo "$input" | jq -r '.effort.level // empty')
# Fall back to the env var if the JSON field is absent
[ -z "$effort" ] && effort="$CLAUDE_EFFORT"
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
# duration=$(echo "$input" | jq -r '.cost.total_duration_ms // empty')

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
		parts="$parts$(printf '\033[35m \302\267 %s\033[0m' "$effort")"
	fi
fi

# Context remaining: green normally, red when low (show only after first API call)
if [ -n "$remaining" ]; then
	[ -n "$parts" ] && parts="$parts  "
	remaining_int=$(printf '%.0f' "$remaining")
	if [ "$remaining_int" -le 20 ]; then
		parts="$parts$(printf '\033[31m%s%%\033[0m' "$remaining_int")"
	else
		parts="$parts$(printf '\033[32m%s%%\033[0m' "$remaining_int")"
	fi
fi

# Cost in USD (yellow), shown only when non-zero
if [ -n "$cost" ]; then
	cost_fmt=$(printf '%.2f' "$cost")
	if [ "$cost_fmt" != "0.00" ]; then
		[ -n "$parts" ] && parts="$parts  "
		parts="$parts$(printf '\033[33m$%s\033[0m' "$cost_fmt")"
	fi
fi

# # Disabled for now — keep for potential future use
# # Elapsed time (blue), formatted as s / m / h+m
# if [ -n "$duration" ]; then
# 	ms=$(printf '%.0f' "$duration")
# 	secs=$((ms / 1000))
# 	if [ "$secs" -lt 60 ]; then
# 		elapsed="${secs}s"
# 	elif [ "$secs" -lt 3600 ]; then
# 		elapsed="$((secs / 60))m"
# 	else
# 		elapsed="$((secs / 3600))h$(((secs % 3600) / 60))m"
# 	fi
# 	[ -n "$parts" ] && parts="$parts  "
# 	parts="$parts$(printf '\033[34m%s\033[0m' "$elapsed")"
# fi

printf '%s' "$parts"
