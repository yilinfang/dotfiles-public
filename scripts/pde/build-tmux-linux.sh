#!/usr/bin/env bash

# This script generates a single, statically-linked tmux executable in the
# ~/.local/bin. All source code, intermediate files, and compiled
# libraries are stored in a temporary directory that is automatically
# removed when the script finishes.

set -euo pipefail

# If in MacOS, notify and exit
if [[ "$(uname)" == "Darwin" ]]; then
	echo "This script is intended for Linux systems only."
	echo "For MacOS, please use homebrew with 'brew install tmux'."
	exit 1
fi

# --- Configuration ---
NCURSES_VERSION="6.6"
LIBEVENT_VERSION="2.1.12-stable"
TMUX_VERSION="3.6a"

# --- Script Start ---

#  Set ~/.local/bin as the default output directory.
readonly OUTPUT_DIR="${HOME}/.local/bin"

# Create a temporary directory for the entire build process.
readonly BUILD_DIR="$(mktemp -d -t tmux-build-XXXXXX)"

# Set up a trap to clean up the temporary directory on exit (including on error).
trap 'echo "--- Cleaning up temporary build directory: ${BUILD_DIR}"; rm -rf "${BUILD_DIR}"' EXIT

echo "--- Starting static build process ---"
echo "Temporary build directory: ${BUILD_DIR}"
echo "Final binary will be placed in: ${OUTPUT_DIR}"

# Define paths inside our temporary build directory.
readonly LOCAL_INSTALL_DIR="${BUILD_DIR}/local"
readonly SRC_DIR="${BUILD_DIR}/sources"
mkdir -p "${LOCAL_INSTALL_DIR}" "${SRC_DIR}"

# Set environment variables for the build process to use our temporary locations.
export CFLAGS="-I${LOCAL_INSTALL_DIR}/include"
export CPPFLAGS="-I${LOCAL_INSTALL_DIR}/include"
export LDFLAGS="-L${LOCAL_INSTALL_DIR}/lib"
export PKG_CONFIG_PATH="${LOCAL_INSTALL_DIR}/lib/pkgconfig"

# --- libevent ---
echo "--- Compiling libevent ${LIBEVENT_VERSION} ---"
cd "${SRC_DIR}"
wget -qO- "https://github.com/libevent/libevent/releases/download/release-${LIBEVENT_VERSION}/libevent-${LIBEVENT_VERSION}.tar.gz" | tar -xzf -
cd "libevent-${LIBEVENT_VERSION}"
./configure --prefix="$LOCAL_INSTALL_DIR" --disable-openssl >/dev/null
make -j$(nproc) -s
make install -s
echo "--- Libevent installation complete ---"

# --- ncurses ---
echo "--- Compiling ncurses ${NCURSES_VERSION} ---"
cd "${SRC_DIR}"
wget -qO- "https://invisible-island.net/archives/ncurses/ncurses-${NCURSES_VERSION}.tar.gz" | tar -xzf -
cd "ncurses-${NCURSES_VERSION}"
./configure --prefix="$LOCAL_INSTALL_DIR" --with-pkg-config-libdir="$LOCAL_INSTALL_DIR/lib/pkgconfig" >/dev/null
make -j$(nproc) -s
make install -s
echo "--- Ncurses installation complete ---"

# --- tmux (static) ---
echo "--- Compiling static tmux ${TMUX_VERSION} ---"
cd "${SRC_DIR}"
wget -qO- "https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz" | tar -xzf -
cd "tmux-${TMUX_VERSION}"
./configure --enable-static --disable-utf8proc --prefix="$LOCAL_INSTALL_DIR" >/dev/null
make -j$(nproc) -s
echo "--- Static tmux build complete ---"

# Copy the final binary to the original directory.
cp tmux "${OUTPUT_DIR}/tmux"

# --- Final Instructions ---
echo
echo "--- Build successful! ---"
echo
echo "The static tmux executable has been generated in:"
echo "  ${OUTPUT_DIR}/tmux"
echo
echo "You can verify that it is a static executable by running:"
echo "  file ${OUTPUT_DIR}/tmux"
echo "  ldd ${OUTPUT_DIR}/tmux"
echo
echo "The temporary build files have been removed."
