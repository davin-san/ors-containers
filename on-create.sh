#!/bin/bash
set -e # Exit immediately if any command fails

# This file acts as a flag. If it exists, we don't re-run setup.
# This ensures your repos are only cloned ONCE.
SETUP_FLAG="/workspace/.setup-complete"

if [ -f "$SETUP_FLAG" ]; then
    echo "Workspace already initialized. Skipping setup."
    # We still run gem5-build, just in case the container was
    # rebuilt and code was pulled. ccache will make it fast.
    echo "Running gem5-build to be safe..."
    /usr/local/bin/gem5-build
    exit 0
fi

echo "--- Initializing New Dev Workspace ---"

# 1. Create the workspace file for VS Code
echo "Creating VS Code workspace file..."
cat << 'EOF' > /workspace/ors-dev.code-workspace
{
    "folders": [
        { "path": "/workspace/garnet-web-visualizer" },
        { "path": "/workspace/gem5-tracer" }
    ],
    "settings": {
        "window.title": "${dirty}${activeEditorShort}${separator}${rootName} (ORS Dev)"
    }
}
EOF

# 2. Run the initial slow build (populates ccache)
echo "Running initial gem5 build. This will be slow..."
/usr/local/bin/gem5-build

# 3. Create the flag file to prevent this from running again
touch $SETUP_FLAG
echo "--- Workspace initialization complete! ---"