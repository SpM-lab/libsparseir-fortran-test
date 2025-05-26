#!/bin/bash
set -e

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Create build directory
mkdir -p build
cd build

# Configure with tests enabled
cmake .. \
  -DCMAKE_C_FLAGS="-w " \
  -DCMAKE_CXX_FLAGS="-w " \
  -DCMAKE_EXE_LINKER_FLAGS=" "


# Build (including tests)
cmake --build . --config Release -j 4

# Run
./test_sparseir_fortran
