#!/usr/bin/env sh

# helpers.sh
# Shared helpers for init.sh and init.zsh (source, do not execute).

# Add a directory to PATH without duplicates. The directory does not have to
# exist yet, so a tool installed later in the session is still found.
add_path_without_duplicate() {
	local dir="${1%/}"
	[[ -n "$dir" ]] || return
	if [[ ":$PATH:" != *":$dir:"* ]]; then
		export PATH="$dir:$PATH"
	fi
}

# Define an alias only if the name is not already taken (command, builtin,
# alias, or function). Warns and skips on collision instead of clobbering.
safe_alias() {
	if command -v -- "$1" >/dev/null 2>&1; then
		printf 'safe_alias: skipping %s (already defined)\n' "$1" >&2
		return
	fi
	alias "$1=$2"
}
