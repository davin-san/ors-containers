# ORS Development Workflow: VS Code + Automated Dev Containers

This repository (`ors-containers`) defines a high-speed, isolated development environment for VS Code. It is designed to house your application code (like `garnet-web-visualizer` and `gem5-tracer`) which is cloned into Docker volumes.

This setup automates the entire build process. You no longer need to manually `docker commit` or manage image tags.

## The Goal

*   **Separate Concerns**: Your environment (this repo) is separate from your application code (`garnet-web-visualizer` and `gem5-tracer`).
*   **Automated First Build**: The first time you open the container, it will automatically clone the required repositories and run the slow `gem5-build` script for you.
*   **Persistent Cache & Source**: All subsequent builds use a persistent `ccache` volume, making incremental compiles incredibly fast. The source code is also stored in a persistent volume, so it is not lost when the container is rebuilt.
*   **Multi-Root Workspace**: VS Code automatically opens both repositories (`garnet-web-visualizer`, `gem5-tracer`) in one window.

## The Automated Workflow

This is the only step you will ever need.

1.  **Launch the Dev Container:**
    *   Open the `ors-containers` folder in VS Code.
    *   A dialog will pop up. Click "Reopen in Container".

2.  **Wait.** The first time you do this, VS Code will:
    *   Build your `gem5-dev.Dockerfile` (if it's not already built).
    *   Start the container.
    *   Automatically clone the `gem5-tracer` and `garnet-web-visualizer` repositories into named volumes.
    *   Automatically run the `gem5-build` script (this is the one-time slow compile). You will see the build output in the VS Code terminal.
    *   Once finished, VS Code will connect, and your multi-root workspace will be open. Your code is compiled, and your `ccache` volume is populated.

3.  **Daily Development:**
    *   Open `ors-containers` in VS Code.
    *   Click "Reopen in Container".
    *   It will instantly connect to your existing, pre-compiled container (it will not re-run the slow build).
    *   You are ready to code.

## How to...

### ...Re-compile gem5?

You've edited code in `gem5-tracer` and want to build it.

1.  Open the VS Code terminal (it's already inside the container).
2.  Run the build command:
    ```bash
    gem5-build
    ```
    This will be an extremely fast incremental build thanks to `ccache`.

### ...Fix a Broken Code Build?

You edited `gem5-tracer`, and now `gem5-build` fails.

1.  You don't need to touch the container. Just use `git`.
2.  Right-click the `gem5-tracer` folder in the sidebar -> "Open in Integrated Terminal".
3.  Run `git checkout .` or `git stash` to revert your changes.
4.  Run `gem5-build` again. It will be fast.

### ...Update the Tools (e.g., install a new apt package)?

You add `vim` to your `gem5-dev.Dockerfile` and want the change.

1.  Make your edits to `gem5-dev.Dockerfile`.
2.  Open the VS Code Command Palette (`Ctrl+Shift+P`).
3.  Run `Dev Containers: Rebuild Container`.
4.  Wait. This will create a new container and re-run the `gem5-build` script once.
    *   This build will still be fast because it will re-use your existing `gem5-ccache` volume. Your source code will also be preserved as it is stored in a named volume.

### ...Fix a Completely Broken Container?

You `rm -rf /` by accident and the container is dead.

1.  Open the VS Code Command Palette (`Ctrl+Shift+P`).
2.  Run `Dev Containers: Rebuild Container`.
    *   This creates a fresh container and re-runs `gem5-build`, which will be fast thanks to the `ccache` volume. You lose no compiled work or source code.
