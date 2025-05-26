# libsparseir-fortran-test

A test project for using [libsparseir](https://github.com/SpM-lab/libsparseir) from Fortran.

## Overview

This repository provides a CMake-based setup for testing and using the libsparseir C++ library from Fortran code. The libsparseir library implements the sparse intermediate representation (IR) for correlation functions, providing efficient routines for:

- On-the-fly computation of basis functions for arbitrary cutoff Λ
- High-precision basis functions and singular values
- Sparse sampling routines

## Prerequisites

- **CMake** (>= 3.10)
- **Fortran compiler** (gfortran, ifort, etc.)
- **C++ compiler** with C++11 support
- **Git** (for fetching libsparseir)

## Quick Start

### 1. Clone and Build

```bash
git clone https://github.com/SpM-lab/libsparseir-fortran-test.git
cd libsparseir-fortran-test
./build.sh
```

### 2. Run Tests

```bash
cd build
ctest
```

## Build Options

The build script supports several options:

```bash
# Basic build (Release mode)
./build.sh

# Debug build with clean
./build.sh --debug --clean

# Build without tests
./build.sh --no-tests

# Use system-installed libsparseir (if available)
./build.sh --system-libsparseir

# Custom install prefix
./build.sh --install-prefix /usr/local

# Show all options
./build.sh --help
```

## Manual CMake Build

If you prefer to use CMake directly:

```bash
mkdir build
cd build

# Configure
cmake .. -DCMAKE_BUILD_TYPE=Release

# Build
cmake --build .

# Run tests
ctest

# Install (optional)
cmake --install .
```

## CMake Options

- `BUILD_TESTING`: Enable/disable building tests (default: ON)
- `USE_SYSTEM_LIBSPARSEIR`: Use system-installed libsparseir instead of fetching from source (default: OFF)
- `CMAKE_BUILD_TYPE`: Build type (Release/Debug)
- `CMAKE_INSTALL_PREFIX`: Installation prefix

## Project Structure

```
libsparseir-fortran-test/
├── CMakeLists.txt          # Main CMake configuration
├── build.sh                # Build script
├── test/
│   └── test_sparseir.f90   # Test program
└── README.md               # This file
```

## Usage in Your Project

To use this setup in your own project:

1. Copy `CMakeLists.txt` to your project
2. Modify the executable targets to match your source files
3. Adjust the libsparseir dependency configuration as needed

## Related Projects

- [libsparseir](https://github.com/SpM-lab/libsparseir) - C++ implementation
- [sparse-ir](https://github.com/SpM-lab/sparse-ir) - Python implementation
- [SparseIR.jl](https://github.com/SpM-lab/SparseIR.jl) - Julia implementation
- [sparse-ir-fortran](https://github.com/SpM-lab/sparse-ir-fortran) - Pure Fortran implementation

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Citation

If you use sparse-ir in your research, please cite:

- Hiroshi Shinaoka et al., Phys. Rev. B 96, 035147 (2017)
- Jia Li et al., Phys. Rev. B 101, 035144 (2020)
- Markus Wallerberger et al., SoftwareX 21, 101266 (2023)
