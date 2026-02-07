#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Configuration
REPO="yilinfang/dotfiles-public"
BRANCH="${BRANCH:-main}"
BASE_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}/"

# Files to install: source_name -> target_path
# Source is relative to root in repo, target is the actual destination
declare -A FILES=(
	["home/dot_vimrc"]="$HOME/.vimrc"
	["home/dot_tmux.conf"]="$HOME/.tmux.conf"
)

# Backup function
backup_file() {
	local file="$1"
	if [[ -f "$file" ]]; then
		local backup="${file}.backup_$(date +%Y%m%d_%H%M%S)"
		echo "Backing up $file -> $backup"
		cp "$file" "$backup"
	fi
}

# Install a single file
install_file() {
	local source="$1"
	local target="$2"
	local target_dir

	echo "Installing $target..."

	# Backup existing file
	backup_file "$target"

	# Create target directory if it doesn't exist
	target_dir=$(dirname "$target")
	if [[ ! -d "$target_dir" ]]; then
		echo "Creating directory: $target_dir"
		mkdir -p "$target_dir"
	fi

	# Download and install
	curl -fsSL "${BASE_URL}/${source}" -o "$target"
	echo "Done."
}

# Main
echo "=== Quick Dotfiles Install ==="
echo "Repository: ${REPO}"
echo "Branch: ${BRANCH}"
echo ""

for source in "${!FILES[@]}"; do
	target="${FILES[$source]}"
	install_file "$source" "$target"
done

echo ""
echo "=== Installation Complete ==="
echo "Installed files:"
for source in "${!FILES[@]}"; do
	echo "  - ${FILES[$source]}"
done
echo ""
echo "Backups created with .backup_timestamp suffix if originals existed."
