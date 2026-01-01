#!/bin/bash
#
# Script to download and install genisoimage from sources
#

set -e

GENISOIMAGE_VERSION="1.1.11"
CDRTOOLS_VERSION="3.02a09"
BUILD_DIR="build"
INSTALL_PREFIX="${PREFIX:-/usr/local}"

echo "==================================="
echo "genisoimage installer"
echo "==================================="
echo ""
echo "This script will download and install genisoimage from sources."
echo "Installation prefix: ${INSTALL_PREFIX}"
echo ""

# Check if genisoimage is already installed
if command -v genisoimage &> /dev/null; then
    echo "genisoimage is already installed at: $(which genisoimage)"
    echo "Version: $(genisoimage --version 2>&1 | head -n 1)"
    read -p "Do you want to reinstall? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
fi

# Create build directory
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

# Download cdrtools (which includes genisoimage/mkisofs)
echo "Downloading cdrtools ${CDRTOOLS_VERSION}..."
CDRTOOLS_URL="https://sourceforge.net/projects/cdrtools/files/cdrtools-${CDRTOOLS_VERSION}.tar.gz/download"
wget -O cdrtools-${CDRTOOLS_VERSION}.tar.gz "${CDRTOOLS_URL}" || {
    echo "Error: Failed to download cdrtools"
    echo "You can manually download from: https://sourceforge.net/projects/cdrtools/"
    exit 1
}

# Extract
echo "Extracting cdrtools..."
tar -xzf cdrtools-${CDRTOOLS_VERSION}.tar.gz

# Find the extracted directory (version might differ from archive name)
EXTRACTED_DIR=$(tar -tzf cdrtools-${CDRTOOLS_VERSION}.tar.gz | head -1 | cut -d'/' -f1)
if [ ! -d "${EXTRACTED_DIR}" ]; then
    echo "Error: Could not find extracted directory"
    exit 1
fi
cd "${EXTRACTED_DIR}"

# Build and install
echo "Building cdrtools (this may take a few minutes)..."
make

# Check if we need sudo for installation
if [ -w "${INSTALL_PREFIX}/bin" ]; then
    SUDO=""
else
    SUDO="sudo"
    echo "Note: Installation to ${INSTALL_PREFIX} requires sudo privileges"
fi

echo "Installing cdrtools to ${INSTALL_PREFIX}..."
${SUDO} make install INS_BASE="${INSTALL_PREFIX}"

# Create genisoimage symlink (genisoimage is an alternative name for mkisofs)
if [ -f "${INSTALL_PREFIX}/bin/mkisofs" ]; then
    echo "Creating genisoimage symlink..."
    ${SUDO} ln -sf mkisofs "${INSTALL_PREFIX}/bin/genisoimage"
fi

# Verify installation
echo ""
echo "==================================="
echo "Installation complete!"
echo "==================================="
if command -v mkisofs &> /dev/null; then
    echo "mkisofs is now available at: $(which mkisofs)"
    echo "Version: $(mkisofs --version 2>&1 | head -n 1)"
fi
if command -v genisoimage &> /dev/null; then
    echo "genisoimage is now available at: $(which genisoimage)"
else
    echo "Warning: Commands not found in PATH"
    echo "You may need to add ${INSTALL_PREFIX}/bin to your PATH"
    echo "Add this line to your ~/.bashrc or ~/.bash_profile:"
    echo "  export PATH=\"${INSTALL_PREFIX}/bin:\$PATH\""
fi

echo ""
echo "Build files are located in: ${BUILD_DIR}"
echo "You can remove them with: rm -rf ${BUILD_DIR}"
