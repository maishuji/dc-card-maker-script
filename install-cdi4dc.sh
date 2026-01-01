#!/bin/bash
#
# Script to download and build cdi4dc from sources
#

set -e

REPO_URL="https://github.com/Kazade/img4dc.git"
BUILD_DIR="build"
TOOLS_DIR="./tools"

echo "==================================="
echo "cdi4dc installer"
echo "==================================="
echo ""
echo "This script will download and build cdi4dc from sources."
echo "Binary will be installed to: ${TOOLS_DIR}/"
echo ""

# Check if cdi4dc already exists
if [ -f "${TOOLS_DIR}/cdi4dc" ]; then
    echo "cdi4dc already exists in ${TOOLS_DIR}/"
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

if ! command -v cmake &> /dev/null; then
    echo "Error: cmake is not installed. Please install cmake first."
    exit 1
fi

if ! command -v make &> /dev/null; then
    echo "Error: make is not installed. Please install build-essential or equivalent."
    exit 1
fi

# Create build directory
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

# Clone or update repository
if [ -d "img4dc" ]; then
    echo "Updating existing img4dc repository..."
    cd img4dc
    git pull
else
    echo "Cloning img4dc repository..."
    git clone "${REPO_URL}"
    cd img4dc
fi

# Build cdi4dc
echo "Building cdi4dc..."
mkdir -p build
cd build

# Try to build with CMake, adding compatibility flag if needed
if ! cmake .. 2>&1 | grep -q "Configuring done"; then
    echo "Retrying with CMake compatibility flag..."
    cmake -DCMAKE_POLICY_VERSION_MINIMUM=3.5 ..
fi

make

# Find the binary (could be in build/ or build/cdi4dc/)
CDI4DC_BINARY=""
if [ -f "cdi4dc" ]; then
    CDI4DC_BINARY="cdi4dc"
elif [ -f "cdi4dc/cdi4dc" ]; then
    CDI4DC_BINARY="cdi4dc/cdi4dc"
fi

# Check if binary was created
if [ -z "$CDI4DC_BINARY" ] || [ ! -f "$CDI4DC_BINARY" ]; then
    echo "Error: cdi4dc binary was not created"
    echo "Looking for binary in:"
    find . -name "cdi4dc" -type f 2>/dev/null || echo "  No cdi4dc binary found"
    exit 1
fi

# Install to tools directory
echo "Installing cdi4dc to ${TOOLS_DIR}..."
cd ../../../
mkdir -p "${TOOLS_DIR}"
cp "${BUILD_DIR}/img4dc/build/${CDI4DC_BINARY}" "${TOOLS_DIR}/cdi4dc"
chmod +x "${TOOLS_DIR}/cdi4dc"

# Verify installation
echo ""
echo "==================================="
echo "Installation complete!"
echo "==================================="
if [ -f "${TOOLS_DIR}/cdi4dc" ]; then
    echo "cdi4dc is now available at: ${TOOLS_DIR}/cdi4dc"
    echo "Version info:"
    "${TOOLS_DIR}/cdi4dc" --version 2>&1 || "${TOOLS_DIR}/cdi4dc" -h 2>&1 | head -n 3 || echo "Binary exists and is executable"
else
    echo "Error: Installation verification failed"
    exit 1
fi

echo ""
echo "Build files are located in: ${BUILD_DIR}/img4dc"
echo "You can remove them with: rm -rf ${BUILD_DIR}/img4dc"
