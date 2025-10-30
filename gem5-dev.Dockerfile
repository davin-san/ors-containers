# Start from a base OS
FROM ubuntu:22.04

# Avoid interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# --- 1. Install System Dependencies & Build Tools ---
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
    lld \
    clang \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# --- 2. Install Python Dependencies ---
RUN pip install mypy pre-commit streamlit pandas-stubs

# --- 2.5 Setup Gemini CLI ---
# Add the NodeSource repository for Node.js 20.x (LTS)
# Replace 'setup_20.x' with 'setup_current.x' for the latest release
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get remove -y libnode-dev

# Install Node.js (this will also update it if a previous version was installed via apt)
RUN apt-get install -y nodejs

RUN npm install -g @google/gemini-cli

# --- 3. Configure ccache ---
# Set up ccache to be used automatically
RUN ln -s /usr/bin/ccache /usr/local/bin/g++
RUN ln -s /usr/bin/ccache /usr/local/bin/gcc
RUN ln -s /usr/bin/ccache /usr/local/bin/c++
RUN ln -s /usr/bin/ccache /usr/local/bin/cc
RUN ln -s /usr/bin/ccache /usr/local/bin/clang
RUN ln -s /usr/bin/ccache /usr/local/bin/clang++
ENV PATH="/usr/local/bin:${PATH}"

# Tell ccache to ignore __DATE__ and __TIME__ macros,
# which gem5 uses and would otherwise bust the cache on every build.
ENV CCACHE_SLOPPINESS=time_macros

# --- 4. Set workdir to where our code will live ---
WORKDIR /workspace

# --- 5. Add our build and setup scripts ---
COPY gem5-build.sh /usr/local/bin/gem5-build
RUN chmod +x /usr/local/bin/gem5-build

# This is our new setup script
COPY on-create.sh /usr/local/bin/on-create
RUN chmod +x /usr/local/bin/on-create

