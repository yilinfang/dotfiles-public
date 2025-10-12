#!/usr/bin/env bash

# This script is used to build Git for Linux systems.

# Exit immediately if a command exits with a non-zero status.
set -e

# If in MacOS, notify and exit
if [[ "$(uname)" == "Darwin" ]]; then
	echo "This script is intended for Linux systems only."
	echo "For MacOS, please use homebrew with 'brew install git'."
	exit 1
fi

# --- Configuration ---
GIT_VERSION="2.50.1"
GIT_URL="https://www.kernel.org/pub/software/scm/git/git-${GIT_VERSION}.tar.gz"

# --- Script Start ---

# Set ~/.local/bin as the default output directory.
readonly OUTPUT_DIR="${HOME}/.local"

# Create a temporary directory for the entire build process.
readonly BUILD_DIR="$(mktemp -d -t git-build-XXXXXX)"

# Set up a trap to clean up the temporary directory on exit (including on error).
trap 'echo "--- Cleaning up temporary build directory: ${BUILD_DIR}"; rm -rf "${BUILD_DIR}"' EXIT

echo "--- Starting build process ---"
echo "Build directory: ${BUILD_DIR}"
echo "Target directory: ${OUTPUT_DIR}"

cd "${BUILD_DIR}"
# Download and extract the Git source code.
wget "${GIT_URL}" -O git.tar.gz
tar -xzf git.tar.gz --strip-components=1
# Configure the build.
make configure
./configure --prefix="${OUTPUT_DIR}"
make -j "$(nproc)"
make install

echo "--- Build completed successfully ---"
