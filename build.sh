#!/bin/bash

# Build script for libsparseir-fortran-test

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Default values
BUILD_TYPE="Release"
BUILD_DIR="build"
INSTALL_PREFIX=""
USE_SYSTEM_LIBSPARSEIR="OFF"
BUILD_TESTING="ON"
CLEAN_BUILD="false"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --debug)
            BUILD_TYPE="Debug"
            shift
            ;;
        --release)
            BUILD_TYPE="Release"
            shift
            ;;
        --build-dir)
            BUILD_DIR="$2"
            shift 2
            ;;
        --install-prefix)
            INSTALL_PREFIX="$2"
            shift 2
            ;;
        --system-libsparseir)
            USE_SYSTEM_LIBSPARSEIR="ON"
            shift
            ;;
        --no-tests)
            BUILD_TESTING="OFF"
            shift
            ;;
        --clean)
            CLEAN_BUILD="true"
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --debug                 Build in Debug mode (default: Release)"
            echo "  --release               Build in Release mode"
            echo "  --build-dir DIR         Build directory (default: build)"
            echo "  --install-prefix DIR    Installation prefix"
            echo "  --system-libsparseir    Use system-installed libsparseir"
            echo "  --no-tests              Disable building tests"
            echo "  --clean                 Clean build directory before building"
            echo "  --help, -h              Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                      # Basic build"
            echo "  $0 --debug --clean      # Clean debug build"
            echo "  $0 --install-prefix /usr/local  # Build with custom install prefix"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

print_status "Starting build process..."
print_status "Build type: $BUILD_TYPE"
print_status "Build directory: $BUILD_DIR"
print_status "Use system libsparseir: $USE_SYSTEM_LIBSPARSEIR"
print_status "Build testing: $BUILD_TESTING"

# Clean build directory if requested
if [[ "$CLEAN_BUILD" == "true" ]]; then
    print_status "Cleaning build directory..."
    rm -rf "$BUILD_DIR"
fi

# Create build directory
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Prepare CMake arguments
CMAKE_ARGS=(
    "-DCMAKE_BUILD_TYPE=$BUILD_TYPE"
    "-DUSE_SYSTEM_LIBSPARSEIR=$USE_SYSTEM_LIBSPARSEIR"
    "-DBUILD_TESTING=$BUILD_TESTING"
)

if [[ -n "$INSTALL_PREFIX" ]]; then
    CMAKE_ARGS+=("-DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX")
fi

# Configure
print_status "Configuring with CMake..."
cmake "${CMAKE_ARGS[@]}" ..

# Build
print_status "Building..."
cmake --build . --parallel $(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)

# Run tests if enabled
if [[ "$BUILD_TESTING" == "ON" ]]; then
    print_status "Running tests..."
    ctest --output-on-failure
fi

print_success "Build completed successfully!"

# Show next steps
echo ""
print_status "Next steps:"
if [[ "$BUILD_TESTING" == "ON" ]]; then
    echo "  - Run tests: cd $BUILD_DIR && ctest"
    echo "  - Run test directly: ./$BUILD_DIR/test_sparseir_fortran"
fi
if [[ -n "$INSTALL_PREFIX" ]]; then
    echo "  - Install: cd $BUILD_DIR && cmake --install ."
fi