#!/usr/bin/env bash

# This script generates a single, statically-linked tmux executable in the
# ~/.local/bin. All source code, intermediate files, and compiled
# libraries are stored in a temporary directory that is automatically
# removed when the script finishes.

set -euo pipefail

# Exit before creating build state on unsupported systems.
if [[ "$(uname -s)" != "Linux" ]]; then
	echo "This script is intended for Linux systems only."
	exit 1
fi

# --- Configuration ---
NCURSES_VERSION="6.6"
NCURSES_SHA256="355b4cbbed880b0381a04c46617b7656e362585d52e9cf84a67e2009b749ff11"
LIBEVENT_VERSION="2.1.13-stable"
LIBEVENT_SHA256="f7e9383b8c0baa81b687e5b5eecc01beefaf1b19b64151d95ed61647fe7a315c"
TMUX_VERSION="3.7b"
TMUX_SHA256="87f2e99e3b685973f2ca002ffd6ed7e51a5744f7009daae5a15670b6d532db96"

# --- Script Start ---

#  Set ~/.local/bin as the default output directory.
readonly OUTPUT_DIR="${HOME}/.local/bin"
mkdir -p "${OUTPUT_DIR}"

# Create a temporary directory for the entire build process.
BUILD_DIR="$(mktemp -d -t tmux-build-XXXXXX)"
readonly BUILD_DIR
OUTPUT_TMP=""

# Clean up temporary build and output files on exit (including on error).
cleanup() {
	if [[ -n "${OUTPUT_TMP}" ]]; then
		rm -f -- "${OUTPUT_TMP}"
	fi
	echo "--- Cleaning up temporary build directory: ${BUILD_DIR}"
	rm -rf -- "${BUILD_DIR}"
}
trap cleanup EXIT

echo "--- Starting static build process ---"
echo "Temporary build directory: ${BUILD_DIR}"
echo "Final binary will be placed in: ${OUTPUT_DIR}"

# Define paths inside our temporary build directory.
readonly LOCAL_INSTALL_DIR="${BUILD_DIR}/local"
readonly SRC_DIR="${BUILD_DIR}/sources"
mkdir -p "${LOCAL_INSTALL_DIR}" "${SRC_DIR}"

download_and_extract() {
	local url="$1"
	local archive="$2"
	local checksum="$3"

	wget -q -O "${archive}" "${url}"
	printf '%s  %s\n' "${checksum}" "${archive}" | sha256sum --check -
	tar -xzf "${archive}"
}

# Set environment variables for the build process to use our temporary locations.
export CFLAGS="-I${LOCAL_INSTALL_DIR}/include"
export CPPFLAGS="-I${LOCAL_INSTALL_DIR}/include"
export LDFLAGS="-L${LOCAL_INSTALL_DIR}/lib"
export PKG_CONFIG_PATH="${LOCAL_INSTALL_DIR}/lib/pkgconfig"

# --- libevent ---
echo "--- Compiling libevent ${LIBEVENT_VERSION} ---"
cd "${SRC_DIR}"
download_and_extract \
	"https://github.com/libevent/libevent/releases/download/release-${LIBEVENT_VERSION}/libevent-${LIBEVENT_VERSION}.tar.gz" \
	"libevent-${LIBEVENT_VERSION}.tar.gz" \
	"${LIBEVENT_SHA256}"
cd "libevent-${LIBEVENT_VERSION}"
./configure --prefix="$LOCAL_INSTALL_DIR" --disable-openssl >/dev/null
make -j"$(nproc)" -s
make install -s
echo "--- Libevent installation complete ---"

# --- ncurses ---
echo "--- Compiling ncurses ${NCURSES_VERSION} ---"
cd "${SRC_DIR}"
download_and_extract \
	"https://invisible-island.net/archives/ncurses/ncurses-${NCURSES_VERSION}.tar.gz" \
	"ncurses-${NCURSES_VERSION}.tar.gz" \
	"${NCURSES_SHA256}"
cd "ncurses-${NCURSES_VERSION}"
./configure \
	--prefix="$LOCAL_INSTALL_DIR" \
	--enable-pc-files \
	--with-pkg-config-libdir="$LOCAL_INSTALL_DIR/lib/pkgconfig" \
	>/dev/null
make -j"$(nproc)" -s
make install -s
echo "--- Ncurses installation complete ---"

# --- tmux (static) ---
echo "--- Compiling static tmux ${TMUX_VERSION} ---"
cd "${SRC_DIR}"
download_and_extract \
	"https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz" \
	"tmux-${TMUX_VERSION}.tar.gz" \
	"${TMUX_SHA256}"
cd "tmux-${TMUX_VERSION}"
./configure --enable-static --disable-utf8proc --prefix="$LOCAL_INSTALL_DIR" >/dev/null
make -j"$(nproc)" -s
echo "--- Static tmux build complete ---"

# Atomically replace the final binary.
OUTPUT_TMP="$(mktemp "${OUTPUT_DIR}/.tmux.XXXXXX")"
install -m 0755 tmux "${OUTPUT_TMP}"
mv -f -- "${OUTPUT_TMP}" "${OUTPUT_DIR}/tmux"
OUTPUT_TMP=""

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
