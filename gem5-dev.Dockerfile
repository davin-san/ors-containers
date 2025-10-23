# Start from a base OS
FROM ubuntu:22.04

# Avoid interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# --- 1. Install System Dependencies & Build Tools ---
# (This is all that should be in the base image)
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    m4 \
    scons \
    zlib1g \
    zlib1g-dev \
    libprotobuf-dev \
    protobuf-compiler \
    libprotoc-dev \
    libgoogle-perftools-dev \
    python3-dev \
    python3-pip \
    python3-venv \
    doxygen \
    libboost-all-dev \
    libhdf5-serial-dev \
    python3-pydot \
    libpng-dev \
    libelf-dev \
    pkg-config \
    wget \
    tar \
    curl \
    vim \
    ccache \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# --- 2. Install Python Dependencies ---
# Install gemini-cli globally
RUN pip3 install -U google-generativeai

# Install Python tools
RUN pip3 install mypy pre-commit

# --- 3. Configure ccache ---
# Set up ccache to be used automatically
# This creates shims in a directory that's first in the PATH
RUN ln -s /usr/bin/ccache /usr/local/bin/g++
RUN ln -s /usr/bin/ccache /usr/local/bin/gcc
RUN ln -s /usr/bin/ccache /usr/local/bin/c++
RUN ln -s /usr/bin/ccache /usr/local/bin/cc
ENV PATH="/usr/local/bin:${PATH}"

# Set a working directory
WORKDIR /app

# --- 4. Add the build script ---
# This script will now build WHATEVER is in your mounted /app/my-gem5-fork
COPY gem5-build.sh /usr/local/bin/gem5-build
RUN chmod +x /usr/local/bin/gem5-build

