cmake_minimum_required(VERSION 3.10)
project(libsparseir-fortran-test LANGUAGES Fortran C CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Set Fortran standard
set(CMAKE_Fortran_STANDARD 2008)

# Build type
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

# Options
option(BUILD_TESTING "Build tests" ON)
option(USE_SYSTEM_LIBSPARSEIR "Use system-installed libsparseir" OFF)

# Find required packages
find_package(PkgConfig QUIET)

# Setup libsparseir dependency
if(USE_SYSTEM_LIBSPARSEIR)
    # Try to find system-installed libsparseir
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(SPARSEIR REQUIRED libsparseir)

    if(SPARSEIR_FOUND)
        message(STATUS "Found system libsparseir")
        add_library(sparseir INTERFACE)
        target_include_directories(sparseir INTERFACE ${SPARSEIR_INCLUDE_DIRS})
        target_link_libraries(sparseir INTERFACE ${SPARSEIR_LIBRARIES})
        target_compile_options(sparseir INTERFACE ${SPARSEIR_CFLAGS_OTHER})
    endif()
else()
    # Fetch and build libsparseir from source
    include(FetchContent)

    FetchContent_Declare(
        libsparseir
        GIT_REPOSITORY https://github.com/SpM-lab/libsparseir.git
        GIT_TAG main
    )

    # Set options for libsparseir build
    set(SPARSEIR_BUILD_FORTRAN ON CACHE BOOL "Build Fortran bindings for libsparseir")
    set(SPARSEIR_BUILD_TESTING OFF CACHE BOOL "Disable libsparseir tests")

    FetchContent_MakeAvailable(libsparseir)

    # Create alias for consistency
    if(TARGET sparseir_fortran)
        add_library(sparseir ALIAS sparseir_fortran)
    elseif(TARGET sparseir)
        # sparseir target already exists
    else()
        message(FATAL_ERROR "libsparseir targets not found")
    endif()
endif()

# Create test executable
if(BUILD_TESTING)
    enable_testing()

    # Create a simple Fortran test
    add_executable(test_sparseir_fortran
        test/test_sparseir.f90
    )

    # Link with libsparseir
    target_link_libraries(test_sparseir_fortran PRIVATE sparseir)

    # Add test
    add_test(NAME sparseir_fortran_test COMMAND test_sparseir_fortran)

    # Set test properties
    set_tests_properties(sparseir_fortran_test PROPERTIES
        TIMEOUT 300
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    )
endif()

# Installation (currently no targets to install)

# Print configuration summary
message(STATUS "")
message(STATUS "Configuration Summary:")
message(STATUS "  Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "  Fortran compiler: ${CMAKE_Fortran_COMPILER}")
message(STATUS "  C++ compiler: ${CMAKE_CXX_COMPILER}")
message(STATUS "  Build testing: ${BUILD_TESTING}")
message(STATUS "  Use system libsparseir: ${USE_SYSTEM_LIBSPARSEIR}")
message(STATUS "")