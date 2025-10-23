# ORS Development Workflow: VS Code + Pre-compiled Containers

This repository (`ors-containers`) defines a high-speed, isolated development environment. It is designed to "fuse" with your application code (like `garnet-web-visualizer` and `gem5-tracer`) which lives in separate repositories.

## The Goal

*   **Separate Concerns:** Your environment (this repo) is separate from your application code (`garnet-web-visualizer` and `gem5-tracer`).
*   **Build Your Fork:** The `Dockerfile` provides tools. You provide the `gem5` code via your `gem5-tracer` fork.
*   **Fuse & Connect:** VS Code launches a container with the tools. The container "fuses" with your code repos by mounting them as volumes.
*   **Multi-Root Workspace:** VS Code will open both `garnet-web-visualizer` and `gem5-tracer` in the same window.
*   **Snapshot Your Build:** You'll run one initial slow compile of your fork inside the container, then "snapshot" that state as your new pre-compiled base image.
*   **Iterate Fast:** All future builds will use the pre-compiled snapshot and `ccache` for incredibly fast incremental changes.

## Step 1: Initial Setup (Do this once)

### Create your Project Directory:

On your local machine, create a parent folder for all your projects.

```bash
mkdir /my-projects/
cd /my-projects/
```

### Clone Your Repositories:

Clone this workflow repo and your application repo(s) as siblings.

```bash
# Clone this environment repo
git clone https://github.com/davin-san/ors-containers.git

# Clone your web visualizer repo
git clone https://github.com/davin-san/garnet-web-visualizer.git

# Clone your gem5 fork (e.g., v22.1)
git clone https://github.com/davin-san/gem5-tracer.git
```

Your directory structure must look like this:

```
/my-projects/
├── ors-containers/         <-- THIS REPO
│   ├── .devcontainer/
│   ├── .env
│   ├── docker-compose.yml
│   ├── gem5-dev.Dockerfile
│   ├── gem5-build.sh
│   ├── ors-dev.code-workspace
│   └── DEV_WORKFLOW.md
│
├── garnet-web-visualizer/  <-- YOUR APP REPO
│
└── gem5-tracer/            <-- YOUR GEM5 FORK
```

### Build the Tools Image:

This is now very fast as it only installs dependencies.

1.  Open a terminal inside the `/my-projects/ors-containers` directory.
2.  Run the build command. This builds your `gem5-dev.Dockerfile` and tags it `ors-dev:base` (or as set in `.env`).

```bash
docker compose build
```

## Step 2: One-Time gem5 Compile & Snapshot

This is the critical step. You will do this once to create your true pre-compiled base image.

### Launch the Dev Container:

1.  Open the `/my-projects/ors-containers` folder in VS Code.
2.  Click "Reopen in Container" when prompted.

### Run the Initial Slow Build:

VS Code will open and automatically load your workspace. You will see both `garnet-web-visualizer` and `gem5-tracer` in the "Explorer" sidebar.

In the VS Code terminal, run the `gem5-build` command. This will navigate to `/app/gem5-tracer` and run the full `scons` compile.

```bash
gem5-build
```

This will take a long time, but it will only happen once.

### Create Your "Compiled" Snapshot:

While the container is still running, open a separate **HOST** terminal.

Commit the container's state to a new image. Give it a descriptive tag like `v1`.

```bash
# Usage: docker commit <container-name> <new-image-tag>
docker commit ors-dev-container ors-dev:v1
```

### Point to Your New Snapshot:

Your base image is now compiled!

1.  Open the `.env` file (in `ors-containers`).
2.  Change the `IMAGE_TAG` to point to your new snapshot:

```diff
# From:
IMAGE_TAG=ors-dev:base

# To:
IMAGE_TAG=ors-dev:v1
```

### Reload the Container:

1.  In VS Code, open the Command Palette (`Ctrl+Shift+P`).
2.  Type `Dev Containers: Rebuild Container` and run it.

VS Code will restart, this time using your new `ors-dev:v1` image which has your fork already built.

## Step 3: Daily Development Workflow

### Open Project:

Open `/my-projects/ors-containers` in VS Code. It will automatically re-open in your `v1` container and show both project folders.

### Work on Code (Seamlessly):

*   **To edit the visualizer:** Find files in the `garnet-web-visualizer` folder in the sidebar. Right-click the folder and select "Open in Integrated Terminal" to open a terminal there and run `git` commands or `streamlit run Home.py`.
*   **To edit gem5:** Find files in the `gem5-tracer` folder in the sidebar. Edit code.
*   **To re-compile gem5:** Run `gem5-build` in any terminal. This will be an extremely fast incremental build.
*   **To commit gem5 changes:** Right-click the `gem5-tracer` folder, select "Open in Integrated Terminal", and run your `git` commands.

## How to...

### ...Update Your Base gem5 Build?

If you pull major changes into your `gem5-tracer` fork and want to create a new snapshot:

1.  Run `gem5-build` (it might be slow as it builds the new changes).
2.  Commit the container again with a new tag: `docker commit ors-dev-container ors-dev:v2`
3.  Update your `.env` file to point to `ors-dev:v2`.
4.  `Dev Containers: Rebuild Container`.

### ...Go Back to a Backup?

If your current build breaks, just edit your `.env` file to point to an older, working tag (like `ors-dev:v1`) and rebuild the container.

### ...Update the Tools (e.g., install a new apt package)?

1.  Add the `apt-get install` line to your `gem5-dev.Dockerfile`.
2.  Set your `.env` file to build a new base image: `IMAGE_TAG=ors-dev:base`
3.  Run `docker compose build` from your host terminal.
4.  You'll now need to do the "One-Time gem5 Compile" (Step 2) again to create a new compiled snapshot based on these new tools.
