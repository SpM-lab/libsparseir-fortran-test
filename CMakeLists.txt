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
        GIT_TAG fortran_test
    )

    # Set options for libsparseir build
    set(SPARSEIR_BUILD_FORTRAN ON CACHE BOOL "Build Fortran bindings for libsparseir")
    set(SPARSEIR_BUILD_TESTING OFF CACHE BOOL "Disable libsparseir tests")

    FetchContent_MakeAvailable(libsparseir)

    # Ensure proper linking between Fortran and C libraries (like Makefile)
    if(TARGET sparseir_fortran AND TARGET sparseir)
        # Force sparseir_fortran to link with sparseir using CMake policy
        cmake_policy(SET CMP0079 NEW)
        target_link_libraries(sparseir_fortran PRIVATE sparseir)
        message(STATUS "Configured sparseir_fortran to link with sparseir")
    endif()

    # Create alias for consistency
    if(TARGET sparseir_fortran)
        add_library(sparseir ALIAS sparseir_fortran)
        set(SPARSEIR_TARGET sparseir_fortran)
    elseif(TARGET sparseir)
        # sparseir target already exists
        set(SPARSEIR_TARGET sparseir)
    else()
        message(FATAL_ERROR "libsparseir targets not found")
    endif()
endif()

# Port Makefile functionality to CMake
if(BUILD_TESTING)
    enable_testing()

    # Step 1: Create setup target (equivalent to Makefile's setup)
    # This ensures libsparseir libraries are built first
    add_custom_target(libsparseir_setup
        DEPENDS sparseir sparseir_fortran
        COMMENT "Setting up libsparseir libraries (equivalent to Makefile setup)"
    )

    # Link with libsparseir
    target_link_libraries(test_sparseir_fortran PRIVATE sparseir sparseir_fortran)
    target_include_directories(test_sparseir_fortran PRIVATE $<TARGET_PROPERTY:sparseir_fortran,Fortran_MODULE_DIRECTORY>)

                # Step 3: Create script that mimics Makefile's sequential build exactly
    set(BUILD_SCRIPT ${CMAKE_CURRENT_BINARY_DIR}/build_test_sequential.sh)
    file(WRITE ${BUILD_SCRIPT} "#!/bin/bash\n")
    file(APPEND ${BUILD_SCRIPT} "set -e\n")
    file(APPEND ${BUILD_SCRIPT} "echo 'Building libsparseir libraries first (like Makefile setup)...'\n")
    file(APPEND ${BUILD_SCRIPT} "cd ${CMAKE_CURRENT_BINARY_DIR}\n")
    file(APPEND ${BUILD_SCRIPT} "make sparseir sparseir_fortran\n")
    file(APPEND ${BUILD_SCRIPT} "echo 'Libraries built successfully. Now compiling Fortran test...'\n")
    file(APPEND ${BUILD_SCRIPT} "${CMAKE_Fortran_COMPILER} -O2 -g \\\n")
    file(APPEND ${BUILD_SCRIPT} "  -I${MODULE_DIR} \\\n")
    file(APPEND ${BUILD_SCRIPT} "  -L${FORTRAN_LIB_DIR} \\\n")
    file(APPEND ${BUILD_SCRIPT} "  -L${C_LIB_DIR} \\\n")
    file(APPEND ${BUILD_SCRIPT} "  -lsparseir_fortran -lsparseir \\\n")
    file(APPEND ${BUILD_SCRIPT} "  ${TEST_SRC} \\\n")
    file(APPEND ${BUILD_SCRIPT} "  -o ${TEST_EXE}\n")
    file(APPEND ${BUILD_SCRIPT} "echo 'Test executable built successfully!'\n")

    # Step 4: Create target that runs the sequential build script
    add_custom_target(test_sparseir_fortran ALL
        COMMAND chmod +x ${BUILD_SCRIPT}
        COMMAND ${BUILD_SCRIPT}
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMENT "Building test executable using sequential approach (like Makefile)"
        VERBATIM
    )

    # Step 5: Add test that runs with proper environment (like Makefile test target)
    add_test(
        NAME sparseir_fortran_test
        COMMAND ${CMAKE_COMMAND} -E env
            "DYLD_LIBRARY_PATH=${FORTRAN_LIB_DIR}:${C_LIB_DIR}"
            ${TEST_EXE}
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    )

    # Step 6: Set test properties
    set_tests_properties(sparseir_fortran_test PROPERTIES
        TIMEOUT 300
        ENVIRONMENT "DYLD_LIBRARY_PATH=${FORTRAN_LIB_DIR}:${C_LIB_DIR}"
    )

    # Step 7: Create convenience target for running test (like Makefile test target)
    add_custom_target(run_test
        COMMAND ${CMAKE_COMMAND} -E env
            "DYLD_LIBRARY_PATH=${FORTRAN_LIB_DIR}:${C_LIB_DIR}"
            ${TEST_EXE}
        DEPENDS test_sparseir_fortran
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMENT "Running test (equivalent to Makefile test target)"
    )
endif()

# Port additional Makefile targets
# Clean target (equivalent to Makefile clean)
add_custom_target(clean_all
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_CURRENT_BINARY_DIR}
    COMMAND ${CMAKE_COMMAND} -E remove -f test_sparseir_manual
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Clean all build artifacts (equivalent to Makefile clean)"
)

# Help target (equivalent to Makefile help)
add_custom_target(help_makefile
    COMMAND ${CMAKE_COMMAND} -E echo "Available targets ported from Makefile:"
    COMMAND ${CMAKE_COMMAND} -E echo "  all                - Build everything default: make"
    COMMAND ${CMAKE_COMMAND} -E echo "  libsparseir_setup  - Build libsparseir libraries only equivalent to Makefile setup"
    COMMAND ${CMAKE_COMMAND} -E echo "  test_sparseir_fortran - Build test executable"
    COMMAND ${CMAKE_COMMAND} -E echo "  run_test           - Build and run the test equivalent to Makefile test"
    COMMAND ${CMAKE_COMMAND} -E echo "  clean_all          - Clean all build artifacts equivalent to Makefile clean"
    COMMAND ${CMAKE_COMMAND} -E echo "  help_makefile      - Show this help"
    COMMAND ${CMAKE_COMMAND} -E echo ""
    COMMAND ${CMAKE_COMMAND} -E echo "CTest commands:"
    COMMAND ${CMAKE_COMMAND} -E echo "  ctest              - Run tests using CTest"
    COMMENT "Show help equivalent to Makefile help"
)

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