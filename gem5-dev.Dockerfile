# Start from the same base
FROM ubuntu:22.04

# --- Static Build Steps (Runs only once when building the image) ---

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -y update && apt-get -y upgrade && \
    apt-get -y install \
    # Original gem5 dependencies
    build-essential git m4 scons zlib1g zlib1g-dev \
    libprotobuf-dev protobuf-compiler libprotoc-dev libgoogle-perftools-dev \
    python3-dev doxygen libboost-all-dev libhdf5-serial-dev python3-pydot \
    libpng-dev libelf-dev pkg-config pip python3-venv \
    # Ccache for incremental builds
    ccache \
    # Node.js and npm for gemini-cli
    curl \
    nodejs \
    npm \
    # Common VS Code dev container dependencies
    wget \
    gnupg \
    ca-certificates

# --- Install gemini-cli ---
# Installs it globally inside the container
RUN npm install -g @google/gemini-cli

# --- Configure ccache ---
# This is CRITICAL for fast incremental C++ builds
RUN mkdir -p /root/.ccache
ENV CCACHE_DIR=/root/.ccache
# Create shims so g++/gcc are automatically fronted by ccache
RUN ln -s /usr/bin/ccache /usr/local/bin/g++
RUN ln -s /usr/bin/ccache /usr/local/bin/gcc
RUN ln -s /usr/bin/ccache /usr/local/bin/c++
RUN ln -s /usr/bin/ccache /usr/local/bin/cc
ENV PATH="/usr/local/bin:${PATH}"

# Set a working directory
WORKDIR /app

# --- Download and build gem5 (stable) ---
# This is your "pre-compiled snapshot"
# This will be compiled *inside the image*
RUN wget https://github.com/gem5/gem5/archive/refs/tags/v22.1.0.0.tar.gz && \
    tar -xzf v22.1.0.0.tar.gz && \
    rm v22.1.0.0.tar.gz

WORKDIR /app/gem5-22.1.0.0
# IMPORTANT: We use ccache for the build. The first build will be
# slow, but all compiled objects are now stored in /root/.ccache
RUN echo "Compiling gem5... this will take a while."
RUN scons build/NULL/gem5.debug -j $(nproc) PROTOCOL=Garnet_standalone
RUN echo "gem5 build complete."

# --- Install Python Dependencies ---
# We install the visualizer's dependencies into the base image
# We will mount the repo from the host machine.
RUN git clone https://github.com/davin-san/garnet-web-visualizer.git /tmp/app-repo && \
    pip install --no-cache-dir -r /tmp/app-repo/requirements.txt && \
    rm -rf /tmp/app-repo

# --- Final Setup ---
# Set the default workdir for the web visualizer code
WORKDIR /app/garnet-web-visualizer

# NO ENTRYPOINT or CMD.
# This makes the image default to running a persistent shell (/bin/bash),
# which is what VS Code's Dev Containers extension will connect to.

