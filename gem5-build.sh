#!/bin/bash
# This script builds the gem5 source located in your mounted fork directory

# Navigate to your mounted gem5 fork
cd /app/gem5-tracer

echo "=================================================="
echo "Starting gem5 build in: $(pwd)"
echo "Using legacy build (v22.1)..."
echo "=================================================="

# Run the build command
# This will use ccache automatically
scons build/NULL/gem5.debug -j $(nproc) PROTOCOL=Garnet_standalone

echo "=================================================="
echo "Build complete."
echo "=================================================="

