#!/usr/bin/env bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if code CLI is installed
check_code_cli() {
	if ! command -v code >/dev/null 2>&1; then
		echo -e "${RED}Error: VSCode CLI (code) is not installed.${NC}"
		echo "Please install VSCode and ensure 'code' command is available in PATH."
		echo "You can install it from: https://code.visualstudio.com/"
		exit 1
	fi
}

# Get extension ID from .vsix file
get_extension_id() {
	local vsix_file="$1"
	local temp_dir=$(mktemp -d)

	# Extract extension/package.json from .vsix
	unzip -q "$vsix_file" -d "$temp_dir"

	# Read publisher and name from package.json
	local publisher=$(cat "$temp_dir/extension/package.json" | grep -o '"publisher"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4)
	local name=$(cat "$temp_dir/extension/package.json" | grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | cut -d'"' -f4)

	# Cleanup
	rm -rf "$temp_dir"

	if [[ -z "$publisher" || -z "$name" ]]; then
		echo ""
		return 1
	fi

	echo "${publisher}.${name}"
}

# Check if extension is already installed
is_extension_installed() {
	local ext_id="$1"
	code --list-extensions | grep -q "^${ext_id}$"
}

# Download and install a single extension
install_extension() {
	local url="$1"
	local temp_dir=$(mktemp -d)
	local filename=$(basename "$url")
	local download_file="$temp_dir/$filename"

	echo -e "${YELLOW}Downloading: $filename${NC}"

	# Download the file
	if ! curl -fsSL -o "$download_file" "$url"; then
		echo -e "${RED}Error: Failed to download from $url${NC}"
		rm -rf "$temp_dir"
		return 1
	fi

	local vsix_file=""

	# Check file type and process accordingly
	if [[ "$filename" == *.vsix ]]; then
		vsix_file="$download_file"
	elif [[ "$filename" == *.zip ]]; then
		echo -e "${YELLOW}Extracting ZIP file...${NC}"
		unzip -q "$download_file" -d "$temp_dir/extracted"

		# Find .vsix file in extracted contents
		vsix_file=$(find "$temp_dir/extracted" -name "*.vsix" -type f | head -1)

		if [[ -z "$vsix_file" ]]; then
			echo -e "${RED}Error: No .vsix file found in ZIP archive${NC}"
			rm -rf "$temp_dir"
			return 1
		fi
	else
		echo -e "${RED}Error: Unsupported file format. Expected .vsix or .zip${NC}"
		rm -rf "$temp_dir"
		return 1
	fi

	# Get extension ID
	local ext_id=$(get_extension_id "$vsix_file")

	if [[ -z "$ext_id" ]]; then
		echo -e "${YELLOW}Warning: Could not determine extension ID, attempting installation anyway${NC}"
		echo -e "${GREEN}Installing extension from $vsix_file...${NC}"
		code --install-extension "$vsix_file"
	else
		echo -e "${GREEN}Extension ID: $ext_id${NC}"

		# Check if already installed
		if is_extension_installed "$ext_id"; then
			echo -e "${YELLOW}Extension $ext_id is already installed.${NC}"
			read -r -p "Reinstall? [y/N] " response
			case "$response" in
			[yY][eE][sS] | [yY])
				echo -e "${GREEN}Reinstalling extension...${NC}"
				code --install-extension "$vsix_file" --force
				;;
			*)
				echo -e "${YELLOW}Skipping installation.${NC}"
				;;
			esac
		else
			echo -e "${GREEN}Installing extension $ext_id...${NC}"
			code --install-extension "$vsix_file"
		fi
	fi

	# Cleanup
	rm -rf "$temp_dir"
}

# Main execution
main() {
	local plugins_file="${1:-assets/vscode/plugins.txt}"

	echo -e "${GREEN}VSCode Extension Installer${NC}"
	echo "=========================="

	# Check for code CLI
	check_code_cli

	# Check if plugins file exists
	if [[ ! -f "$plugins_file" ]]; then
		echo -e "${RED}Error: Plugins file not found: $plugins_file${NC}"
		exit 1
	fi

	echo -e "${GREEN}Reading extension list from: $plugins_file${NC}"

	# Process each URL in the plugins file
	local count=0
	while IFS= read -r url || [[ -n "$url" ]]; do
		# Skip empty lines and comments
		[[ -z "$url" || "$url" =~ ^[[:space:]]*# ]] && continue

		# Trim whitespace
		url=$(echo "$url" | tr -d '[:space:]')

		[[ -z "$url" ]] && continue

		((count++))
		echo ""
		echo -e "${GREEN}[$count] Processing: $url${NC}"

		install_extension "$url" || echo -e "${RED}Failed to install extension from $url${NC}"
	done <"$plugins_file"

	echo ""
	echo -e "${GREEN}Extension installation complete!${NC}"
	echo -e "${GREEN}Total extensions processed: $count${NC}"
}

# Run main function
main "$@"
