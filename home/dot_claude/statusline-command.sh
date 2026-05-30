#!/usr/bin/env sh
input=$(cat)

cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
duration=$(echo "$input" | jq -r '.cost.total_duration_ms // empty')

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
fi

# Context used: green normally, red when high (show only after first API call)
if [ -n "$remaining" ]; then
	[ -n "$parts" ] && parts="$parts  "
	remaining_int=$(printf '%.0f' "$remaining")
	used=$((100 - remaining_int))
	if [ "$used" -ge 80 ]; then
		parts="$parts$(printf '\033[31m%s%%\033[0m' "$used")"
	else
		parts="$parts$(printf '\033[32m%s%%\033[0m' "$used")"
	fi
fi

# Cost in USD (yellow), shown once there is a cost
if [ -n "$cost" ]; then
	cost_fmt=$(printf '%.2f' "$cost")
	if [ "$cost_fmt" != "0.00" ]; then
		[ -n "$parts" ] && parts="$parts  "
		parts="$parts$(printf '\033[33m$%s\033[0m' "$cost_fmt")"
	fi
fi

# Elapsed time (blue), formatted as s / m / h+m
if [ -n "$duration" ]; then
	ms=$(printf '%.0f' "$duration")
	secs=$((ms / 1000))
	if [ "$secs" -lt 60 ]; then
		elapsed="${secs}s"
	elif [ "$secs" -lt 3600 ]; then
		elapsed="$((secs / 60))m"
	else
		elapsed="$((secs / 3600))h$(((secs % 3600) / 60))m"
	fi
	[ -n "$parts" ] && parts="$parts  "
	parts="$parts$(printf '\033[34m%s\033[0m' "$elapsed")"
fi

printf '%s' "$parts"
