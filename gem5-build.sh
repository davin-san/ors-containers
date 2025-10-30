#!/bin/bash
# This script builds the gem5 source located in /workspace/gem5-tracer

# Navigate to the mounted gem5 fork
cd /workspace/gem5-tracer

# Tell SCons to use the clang++ compiler.
# SCons will automatically detect this and use the
# LLVM linker (lld) with the *correct* (non-GNU) linker flags.
export CXX=clang++
export CC=clang

echo "=================================================="
echo "Starting gem5 build in: $(pwd)"
echo "Running command: scons (with CXX=clang++) build/NULL/gem5.debug -j $(nproc) PROTOCOL=Garnet_standalone"
echo "=================================================="

# Run the build command
# This will use ccache automatically
scons build/NULL/gem5.debug -j $(nproc) PROTOCOL=Garnet_standalone