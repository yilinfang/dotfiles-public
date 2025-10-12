#!/usr/bin/env bash

# Exit on error, undefined variable, or failed command in a pipeline
set -euo pipefail

# Check if mise is installed
if ! command -v mise &>/dev/null; then
	echo "mise is not installed. Please install mise first."
	exit 1
fi

# Install essential tools using mise
mise use -g bat
mise use -g delta
mise use -g difftastic
mise use -g fd
mise use -g fzf
mise use -g lazygit
mise use -g neovim@0.11.4
mise use -g ripgrep
mise use -g ubi:gokcehan/lf
mise use -g zoxide

# Install essential npm packages
# Check if npm is available
if command -v npm &>/dev/null; then
	mise use -g npm:czg
else
	echo "Node is not installed. You can install Node with mise:"
	echo "  mise use -g node"
fi
