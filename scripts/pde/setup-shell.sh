#!/usr/bin/env bash

# Exit on error, undefined variables, or pipe failures.
set -euo pipefail

# --- Configuration ---
SCRIPT_DIR="$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
INIT_SCRIPTS_DIR="$(cd -P -- "${SCRIPT_DIR}/../init" && pwd -P)"
# Calculate relative path from HOME to INIT_SCRIPTS_DIR
RELATIVE_INIT_PATH="${INIT_SCRIPTS_DIR#$HOME/}"

# --- Define the configuration snippets for each shell ---

BASH_CONFIG_SNIPPET=$(
	cat <<EOF
if [ -f "\$HOME/${RELATIVE_INIT_PATH}/init.sh" ]; then
    source "\$HOME/${RELATIVE_INIT_PATH}/init.sh"
fi
EOF
)

ZSH_CONFIG_SNIPPET=$(
	cat <<EOF
if [ -f "\$HOME/${RELATIVE_INIT_PATH}/init.zsh" ]; then
    source "\$HOME/${RELATIVE_INIT_PATH}/init.zsh"
fi
EOF
)

# FISH_CONFIG_SNIPPET=$(
# 	cat <<EOF
# if test -f "\$HOME/${RELATIVE_INIT_PATH}/init.fish"
#     source "\$HOME/${RELATIVE_INIT_PATH}/init.fish"
# end
# EOF
# )

# --- Main Logic ---

backup() {
	local file="$1"
	if [ -f "$file" ]; then
		local timestamp
		timestamp=$(date +"%Y%m%d_%H%M%S")
		local backup_file="${file}.backup_${timestamp}"
		echo "Setup: Backing up existing file ${file} to ${backup_file}..."
		cp "$file" "$backup_file"
	fi
}

add_config() {
	local config_file="$1"
	local snippet="$2"
	local marker_line
	marker_line=$(echo "$snippet" | head -n 1)
	if [ ! -f "$config_file" ]; then touch "$config_file"; fi
	if grep -qF -- "$marker_line" "$config_file"; then
		echo "Setup: Configuration already exists in ${config_file}."
	else
		backup "$config_file"
		echo "Setup: Adding shell configuration to ${config_file}..."
		printf "\n%s\n" "$snippet" >>"$config_file"
	fi
}

current_shell=$(basename "${SHELL}")
echo "Setup: Detected default shell: ${current_shell}"
case "${current_shell}" in
bash) add_config "${HOME}/.bashrc" "$BASH_CONFIG_SNIPPET" ;;
zsh) add_config "${ZDOTDIR:-$HOME}/.zshrc" "$ZSH_CONFIG_SNIPPET" ;;
# fish)
# 	config_file="${HOME}/.config/fish/config.fish"
# 	mkdir -p "$(dirname "$config_file")"
# 	add_config "$config_file" "$FISH_CONFIG_SNIPPET"
# 	;;
*) echo "Setup: Unsupported shell ('${current_shell}')." ;;
esac
