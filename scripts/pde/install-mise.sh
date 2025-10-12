#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Default Configuration ---
INSTALL_DIR="${HOME}/.local/bin"
MISE_VERSION_SPEC="latest"

# --- Help and Usage Function ---
usage() {
	cat <<EOF
Usage: $(basename "$0") [options]

This script installs mise.

Options:
  -d, --install-dir <path>  Set the installation directory.
                            (Default: ${HOME}/.local/bin)
  -v, --version <v>         Set the version of mise to install.
                            (Default: latest)
  -h, --help                Show this help message.
EOF
}

# --- Argument Parsing ---
while [ "$#" -gt 0 ]; do
	case "$1" in
	-d | --install-dir)
		if [ -z "$2" ] || [[ "$2" == -* ]]; then
			echo "Error: --install-dir requires a non-empty argument." >&2
			exit 1
		fi
		INSTALL_DIR="$2"
		shift 2
		;;
	-v | --version)
		if [ -z "$2" ] || [[ "$2" == -* ]]; then
			echo "Error: --version requires a non-empty argument." >&2
			exit 1
		fi
		MISE_VERSION_SPEC="$2"
		shift 2
		;;
	-h | --help)
		usage
		exit 0
		;;
	*)
		echo "Unknown option: $1" >&2
		usage
		exit 1
		;;
	esac
done

# --- Display Configuration ---
echo "--- Configuration ---"
echo "Installation Directory: ${INSTALL_DIR}"
echo "mise Version Spec:      ${MISE_VERSION_SPEC}"
echo "---------------------"

# --- Version Resolution ---
if [ "${MISE_VERSION_SPEC}" = "latest" ]; then
	echo "Querying GitHub API for the latest mise version..."
	MISE_VERSION=$(curl -sSL "https://api.github.com/repos/jdx/mise/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
	if [ -z "$MISE_VERSION" ]; then
		echo "Error: Could not determine latest mise version. GitHub API limit may have been reached." >&2
		exit 1
	fi
else
	MISE_VERSION="${MISE_VERSION_SPEC}"
fi

echo
echo "--- Installation Plan ---"
echo "Installing mise version: ${MISE_VERSION}"
echo "-------------------------"
echo

# --- Setup ---
mkdir -p "${INSTALL_DIR}"

# --- Platform Detection ---
case "$(uname -s)" in
Linux)
	MISE_OS='linux'
	;;
Darwin)
	MISE_OS='macos'
	;;
*)
	echo "Unsupported OS: $(uname -s)" >&2
	exit 1
	;;
esac

case "$(uname -m)" in
x86_64)
	MISE_ARCH='x64'
	;;
arm64 | aarch64)
	MISE_ARCH='arm64'
	;;
*)
	echo "Unsupported architecture: $(uname -m)" >&2
	exit 1
	;;
esac

# --- Installation Process ---
TMP_DIR=$(mktemp -d)
trap 'rm -rf -- "$TMP_DIR"' EXIT
cd "${TMP_DIR}"

# --- Install mise ---
echo "Downloading mise v${MISE_VERSION}..."
MISE_FILENAME="mise-v${MISE_VERSION}-${MISE_OS}-${MISE_ARCH}.tar.gz"
MISE_URL="https://github.com/jdx/mise/releases/download/v${MISE_VERSION}/${MISE_FILENAME}"

curl -fsSL -o "${MISE_FILENAME}" "${MISE_URL}"
echo "Extracting and locating mise binary..."
tar -xzf "${MISE_FILENAME}"

MISE_PATH=$(find . -type f -name mise)
if [ ! -f "$MISE_PATH" ]; then
	echo "Error: Could not find 'mise' binary in the downloaded archive." >&2
	exit 1
fi

mv "$MISE_PATH" "${INSTALL_DIR}/mise"
chmod +x "${INSTALL_DIR}/mise"
echo "mise v${MISE_VERSION} installed successfully."
echo

# --- Verification ---
echo "Verifying installation..."
"${INSTALL_DIR}/mise" --version
echo

# --- PATH Configuration ---
# Function to add a configuration line to a file if it does not already exist.
add_to_config_if_missing() {
	local config_file="$1"
	local line_to_add="$2"
	local comment="# Added by mise installation script on $(date)"

	# Ensure the directory for the config file exists, especially for fish.
	mkdir -p "$(dirname "${config_file}")"
	# Ensure the config file itself exists.
	touch "${config_file}"

	if ! grep -qF -- "$line_to_add" "$config_file"; then
		echo "-> Updating ${config_file} to include ${INSTALL_DIR} in PATH."
		printf "\n%s\n%s\n" "$comment" "$line_to_add" >>"$config_file"
		echo "   Success. Please restart your shell or run 'source ${config_file}' for the changes to take effect."
	else
		echo "-> ${INSTALL_DIR} is already configured in ${config_file}."
	fi
}

# Check if INSTALL_DIR is already in the current shell's PATH.
# The colons are used to ensure we match the full path and not a substring.
case ":$PATH:" in
*":${INSTALL_DIR}:"*)
	echo "${INSTALL_DIR} is already in your PATH for the current session."
	;;
*)
	echo "${INSTALL_DIR} is not in your current PATH."
	# Ask the user for permission to modify their shell configuration.
	read -p "Would you like to add it to your shell configuration file? (y/n) " -n 1 -r

	if [[ $REPLY =~ ^[Yy]$ ]]; then
		current_shell=$(basename "${SHELL}")
		echo "-> Detected shell: ${current_shell}"
		case "${current_shell}" in
		bash)
			config_file="${HOME}/.bashrc"
			# Note the escaped $PATH, so it is evaluated on shell startup, not now.
			line="export PATH=\"${INSTALL_DIR}:\$PATH\""
			add_to_config_if_missing "$config_file" "$line"
			;;
		zsh)
			config_file="${ZDOTDIR:-$HOME}/.zshrc"
			line="export PATH=\"${INSTALL_DIR}:\$PATH\""
			add_to_config_if_missing "$config_file" "$line"
			;;
		fish)
			config_file="${HOME}/.config/fish/config.fish"
			# fish has a special function for this to avoid duplicates automatically.
			line="fish_add_path -g \"${INSTALL_DIR}\""
			add_to_config_if_missing "$config_file" "$line"
			;;
		*)
			echo "   Unsupported shell ('${current_shell}')."
			echo "   Please add the following line to your shell's configuration file:"
			echo "   export PATH=\"${INSTALL_DIR}:\$PATH\""
			;;
		esac
	else
		echo "Skipping PATH modification. Please add '${INSTALL_DIR}' to your PATH manually to use mise."
	fi
	;;
esac

# --- Final Instructions ---
echo "mise installation complete."
echo "Ensure '${INSTALL_DIR}' is in your PATH."
