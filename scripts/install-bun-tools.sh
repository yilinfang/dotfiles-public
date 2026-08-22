#!/usr/bin/env bash

# Check if bun is installed
if ! command -v bun &>/dev/null; then
	echo "bun is not installed. Please install bun first."
	exit 1
fi

# Define the list of tools to install
tools=(
	"ccusage"
	"czg"
)

# Install each tool using bun
for tool in "${tools[@]}"; do
	if ! bun install -g "$tool"; then
		echo "Failed to install $tool. Please check for errors."
		exit 1
	fi
	echo "$tool installed successfully."
done
