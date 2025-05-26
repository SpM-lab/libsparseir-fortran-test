# Makefile for libsparseir-fortran-test
# This uses manual compilation approach that works

# Compiler settings
FC = gfortran
FCFLAGS = -O2 -g

# Build directory
BUILD_DIR = build

# libsparseir directories (after CMake build)
LIBSPARSEIR_BUILD_DIR = $(BUILD_DIR)/_deps/libsparseir-build
FORTRAN_LIB_DIR = $(LIBSPARSEIR_BUILD_DIR)/fortran
C_LIB_DIR = $(LIBSPARSEIR_BUILD_DIR)
MODULE_DIR = $(FORTRAN_LIB_DIR)/fortran

# Library flags
LDFLAGS = -L$(FORTRAN_LIB_DIR) -L$(C_LIB_DIR) -lsparseir_fortran -lsparseir
FCFLAGS += -I$(MODULE_DIR)

# Source files
TEST_SRC = test/test_sparseir.f90
TEST_EXE = test_sparseir_manual

# Default target
all: setup $(TEST_EXE)

# Setup: build libsparseir using CMake
setup:
	@echo "Building libsparseir using CMake..."
	@mkdir -p $(BUILD_DIR)
	@cd $(BUILD_DIR) && cmake .. -DSPARSEIR_BUILD_FORTRAN=ON -DSPARSEIR_BUILD_TESTING=OFF
	@cd $(BUILD_DIR) && make sparseir sparseir_fortran

# Build test executable
$(TEST_EXE): $(TEST_SRC) setup
	@echo "Compiling Fortran test..."
	$(FC) $(FCFLAGS) $(LDFLAGS) $(TEST_SRC) -o $(TEST_EXE)

# Run test
test: $(TEST_EXE)
	@echo "Running test..."
	DYLD_LIBRARY_PATH=$(FORTRAN_LIB_DIR):$(C_LIB_DIR) ./$(TEST_EXE)

# Clean
clean:
	rm -rf $(BUILD_DIR) $(TEST_EXE)

# Help
help:
	@echo "Available targets:"
	@echo "  all     - Build everything (default)"
	@echo "  setup   - Build libsparseir libraries only"
	@echo "  test    - Build and run the test"
	@echo "  clean   - Clean all build artifacts"
	@echo "  help    - Show this help"

.PHONY: all setup test clean help
