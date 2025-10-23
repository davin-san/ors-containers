# gem5 Development Workflow: VS Code + Pre-compiled Containers
This repository (ors-containers) defines a high-speed, isolated development environment. It is designed to "fuse" with your application code (like garnet-web-visualizer) which lives in a separate repository.

## The Goal

*   **Separate Concerns**: Your environment (this repo) is separate from your application code (garnet-web-visualizer and gem5-tracer).
*   **Build Once**: We build the slow gem5 project once inside a Docker image.
*   **Fuse & Connect**: VS Code uses the files in this repo to build and launch a container. The container "fuses" with your other repos by mounting them as volumes.
*   **Iterate Fast**: Re-compiling gem5 uses a persistent ccache volume, making incremental builds incredibly fast.
*   **Snapshot Backups**: New "working" compiled states can be committed as new, tagged "backup" images.

## Step 1: Initial Setup (Do this once)

**Create your Project Directory:**

On your local machine, create a parent folder for all your projects.

```bash
mkdir /my-projects/
cd /my-projects/
```

**Clone Your Repositories:**

Clone this workflow repo and your application repo(s) as siblings.

```bash
# Clone this environment repo
git clone https://github.com/davin-san/ors-containers.git

# Clone your web visualizer repo
git clone https://github.com/davin-san/garnet-web-visualizer.git

# Clone your gem5 fork
git clone https://github.com/davin-san/gem5-tracer.git
```

Your directory structure must look like this:

```
/my-projects/
├── ors-containers/      <-- THIS REPO
│   ├── .devcontainer/
│   │   └── devcontainer.json
│   ├── .env
│   ├── docker-compose.yml
│   ├── gem5-dev.Dockerfile
│   └── README.md
│
├── garnet-web-visualizer/  <-- YOUR APP REPO
│
└── gem5-tracer/           <-- YOUR GEM5 FORK
```

**Build the Base Image:**

This is the one-time slow build.

1.  Open a terminal inside the `/my-projects/ors-containers` directory.
2.  Run the build command. This reads your `docker-compose.yml` and `gem5-dev.Dockerfile` and builds the image.
3.  It will be automatically tagged as `gem5-dev:latest` (or whatever is in your `.env` file).

```bash
# Make sure you are in the /my-projects/gem5-dev-workflow/ directory
# This will take a long time as it compiles gem5
docker compose build
```

## Step 2: The Daily Development Workflow

1.  **Install VS Code Extension**: Make sure you have the "Dev Containers" extension installed in VS Code.
2.  **Open Your Project**:
    *   Open VS Code.
    *   Go to `File > Open Folder...`
    *   Select the `/my-projects/ors-containers` folder.
3.  **Launch Container**:
    *   VS Code will detect the `.devcontainer/devcontainer.json` file.
    *   A pop-up will appear: "Folder contains a Dev Container... Reopen in Container?"
    *   Click "Reopen in Container".
4.  **You're In!**
    *   VS Code will launch your container using the image specified in the `.env` file (e.g., `gem5-dev:latest`).
    *   Your VS Code file explorer and terminal will automatically open in `/app/garnet-web-visualizer`.
    *   Your local `garnet-web-visualizer` and `gem5-tracer` folders are now "fused" with the container.
    *   Type `gemini --version` in the terminal to confirm `gemini-cli` is working.

**Using Your Custom gem5 Command**
The container has a custom build script.
1.  From the VS Code terminal (which is already in `/app/garnet-web-visualizer`), navigate to your gem5 fork's directory:

```bash
cd /app/my-gem5-fork
```
2.  To build your gem5 fork (this will use ccache for a fast incremental build):

```bash
gem5-build
```


## Step 3: How to "Update" and "Backup"

### Updating Your Base Image

**Scenario**: You've made a permanent improvement (e.g., added a new tool to `gem5-dev.Dockerfile`) and want to make this your new default.

1.  Make your changes to `gem5-dev.Dockerfile`.
2.  From your host terminal (in the `gem5-dev-workflow` folder), just re-run the build command:

```bash
docker compose build
```

This will build a new image and tag it as `gem5-dev:latest`, replacing the old one. The next time you launch your dev container, it will use the new version.

### Creating a Backup Snapshot (e.g., "v1")

**Scenario**: Your current `gem5` build is working perfectly, and you want to save it as a "backup" (e.g., `gem5-dev:v1`) before trying something risky.

1.  Keep the container running.
2.  Open a separate HOST terminal.
3.  Commit the container's state using `docker commit`:

```bash
# Usage: docker commit <container-name> <new-image-tag>
docker commit gem5-dev-container gem5-dev:v1
```

You're done. You now have `gem5-dev:latest` (your main image) and `gem5-dev:v1` (your backup).

### How to Go Back to a Backup

**Scenario**: You broke your `latest` build and want to go back to your `gem5-dev:v1` backup.

1.  Open the `.env` file in this repo.
2.  Change the tag:

```diff
# From:
IMAGE_TAG=gem5-dev:latest

# To:
IMAGE_TAG=gem5-dev:v1
```

3.  Save the file.
4.  Relaunch the dev container from VS Code. It will now use the `gem5-dev:v1` image.
