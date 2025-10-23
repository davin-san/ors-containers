# Start from a base OS
FROM ubuntu:22.04

# Avoid interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# --- Install Base Dependencies & Build Tools ---
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    m4 \
    scons \
    zlib1g zlib1g-dev \
    libprotobuf-dev protobuf-compiler libprotoc-dev \
    libgoogle-perftools-dev \
    python3-dev \
    doxygen \
    libboost-all-dev \
    libhdf5-serial-dev \
    python3-pydot \
    libpng-dev \
    libelf-dev \
    pkg-config \
    pip \
    python3-venv \
    wget \
    tar \
    curl \
    ccache \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# --- Configure ccache ---
RUN mkdir -p /root/.ccache
ENV CCACHE_DIR=/root/.ccache
# Set up ccache to be used automatically
RUN ln -s /usr/bin/ccache /usr/local/bin/g++
RUN ln -s /usr/bin/ccache /usr/local/bin/gcc
RUN ln -s /usr/bin/ccache /usr/local/bin/c++
RUN ln -s /usr/bin/ccache /usr/local/bin/cc
ENV PATH="/usr/local/bin:${PATH}"

# --- Build gem5 (stable) ---
# This pre-builds the v22.1.0.0 version.
# Your mounted gem5-fork will be used for active development.
WORKDIR /app
RUN wget https://github.com/gem5/gem5/archive/refs/tags/v22.1.0.0.tar.gz && \
    tar -xzf v22.1.0.0.tar.gz && \
    rm v22.1.0.0.tar.gz

WORKDIR /app/gem5-22.1.0.0
RUN scons build/NULL/gem5.debug -j $(nproc) PROTOCOL=Garnet_standalone

# --- Install Python Dependencies for Visualizer ---
# Temporarily clone the repo to get the requirements.txt, then remove it.
RUN git clone https://github.com/davin-san/garnet-web-visualizer.git /tmp/app-repo && \
    pip install --no-cache-dir -r /tmp/app-repo/requirements.txt && \
    rm -rf /tmp/app-repo

# --- Install gemini-cli ---
RUN npm install -g @google-ai/gemini-cli

# --- Add custom gem5 build/run scripts ---
# These scripts can be run from the gem5 directory (e.S., /app/my-gem5-fork)

# Simplified build script for gem5 v22.1
RUN echo '#!/bin/bash' > /usr/local/bin/gem5-build && \
    echo '# Builds gem5 for v22.1 (and similar)' >> /usr/local/bin/gem5-build && \
    echo 'set -e' >> /usr/local/bin/gem5-build && \
    echo 'echo "--- Building gem5 (v22.1) ---"' >> /usr/local/bin/gem5-build && \
    echo 'scons build/NULL/gem5.debug -j $(nproc) PROTOCOL=Garnet_standalone' >> /usr/local/bin/gem5-build && \
    echo 'echo "--- Build complete ---"' >> /usr/local/bin/gem5-build && \
    chmod +x /usr/local/bin/gem5-build
# --- End of new scripts ---

# Return to /app for the application code
WORKDIR /app

