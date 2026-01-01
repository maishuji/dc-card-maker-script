#!/bin/bash
#
# Script to download and build cdirip from sources
#

set -e

REPO_URL="https://github.com/jozip/cdirip.git"
BUILD_DIR="build"
TOOLS_DIR="./tools"

echo "==================================="
echo "cdirip installer"
echo "==================================="
echo ""
echo "This script will download and build cdirip from sources."
echo "Binary will be installed to: ${TOOLS_DIR}/"
echo ""

# Check if cdirip already exists
if [ -f "${TOOLS_DIR}/cdirip" ]; then
    echo "cdirip already exists in ${TOOLS_DIR}/"
    read -p "Do you want to reinstall? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
fi

# Check for required build tools
if ! command -v git &> /dev/null; then
    echo "Error: git is not installed. Please install git first."
    exit 1
fi

if ! command -v make &> /dev/null; then
    echo "Error: make is not installed. Please install build-essential or equivalent."
    exit 1
fi

if ! command -v gcc &> /dev/null; then
    echo "Error: gcc is not installed. Please install build-essential or equivalent."
    exit 1
fi

# Create build directory
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

# Clone or update repository
if [ -d "cdirip" ]; then
    echo "Updating existing cdirip repository..."
    cd cdirip
    git pull
else
    echo "Cloning cdirip repository..."
    git clone "${REPO_URL}"
    cd cdirip
fi

# Build cdirip
echo "Building cdirip..."
make

# Check if binary was created
if [ ! -f "cdirip" ]; then
    echo "Error: cdirip binary was not created"
    echo "Looking for binary in:"
    find . -name "cdirip" -type f 2>/dev/null || echo "  No cdirip binary found"
    exit 1
fi

# Install to tools directory
echo "Installing cdirip to ${TOOLS_DIR}..."
cd ../../
mkdir -p "${TOOLS_DIR}"
cp "${BUILD_DIR}/cdirip/cdirip" "${TOOLS_DIR}/cdirip"
chmod +x "${TOOLS_DIR}/cdirip"

# Verify installation
echo ""
echo "==================================="
echo "Installation complete!"
echo "==================================="
if [ -f "${TOOLS_DIR}/cdirip" ]; then
    echo "cdirip is now available at: ${TOOLS_DIR}/cdirip"
    echo "Version info:"
    "${TOOLS_DIR}/cdirip" 2>&1 | head -n 5 || echo "Binary exists and is executable"
else
    echo "Error: Installation verification failed"
    exit 1
fi

echo ""
echo "Build files are located in: ${BUILD_DIR}/cdirip"
echo "You can remove them with: rm -rf ${BUILD_DIR}/cdirip"
