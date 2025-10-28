#!/bin/bash
# This script builds the gem5 source located in /workspace/gem5-tracer

# Navigate to the mounted gem5 fork
cd /workspace/gem5-tracer

echo "=================================================="
echo "Starting gem5 build in: $(pwd)"
echo "=================================================="

# Run the build command
# This will use ccache automatically
scons build/NULL/gem5.debug -j $(nproc) PROTOCOL=Garnet_standalone