# gem5 Development Workflow: VS Code + Pre-compiled Containers

This repository (ors-containers) defines a high-speed, isolated development environment. It is designed to "fuse" with your application code (like garnet-web-visualizer) which lives in a separate repository.

## The Goal

*   **Separate Concerns**: Your environment (this repo) is separate from your application code (garnet-web-visualizer and my-gem5-fork).
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
git clone <url-to-your-gem5-dev-workflow-repo>

# Clone your web visualizer repo
git clone https://github.com/davin-san/garnet-web-visualizer.git

# Clone your gem5 fork
git clone <url-to-your-gem5-fork> my-gem5-fork
```

Your directory structure must look like this:

```
/my-projects/
├── gem5-dev-workflow/      <-- THIS REPO
│   ├── .devcontainer/
│   │   └── devcontainer.json
│   ├── docker-compose.yml
│   ├── gem5-dev.Dockerfile
│   └── DEV_WORKFLOW.md
│
├── garnet-web-visualizer/  <-- YOUR APP REPO
│
└── my-gem5-fork/           <-- YOUR GEM5 FORK
```

**Build the Base Image:**

This is the one-time slow build.

1.  Open a terminal inside the `/my-projects/gem5-dev-workflow` directory.
2.  Run the build command. This reads your `docker-compose.yml` and executes the build step using `gem5-dev.Dockerfile`.

```bash
# Make sure you are in the /my-projects/gem5-dev-workflow/ directory
# This will take a long time as it compiles gem5
docker compose build
```

**Tag the Built Image (Optional but Recommended):**

The `docker compose build` command creates an image with a long name (e.g., `gem5-dev-workflow-dev`). Let's tag it `gem5-dev:v1` for clarity.

```bash
docker tag gem5-dev-workflow-dev gem5-dev:v1
```

**Update docker-compose.yml:**

For much faster startups, we will now tell Docker Compose to use our new `gem5-dev:v1` image instead of re-building every time.

Edit `docker-compose.yml`:

1.  Comment out the `build: .` line.
2.  Uncomment the `image: gem5-dev:v1` line.

**After:**

```yaml
services:
  dev:
    # build: .
    image: gem5-dev:v1
...
```

## Step 2: The Daily Development Workflow

1.  **Install VS Code Extension**: Make sure you have the "Dev Containers" extension installed in VS Code.
2.  **Open Your Project**:
    *   Open VS Code.
    *   Go to `File > Open Folder...`
    *   Select the `/my-projects/gem5-dev-workflow` folder.
3.  **Launch Container**:
    *   VS Code will detect the `.devcontainer/devcontainer.json` file.
    *   A pop-up will appear: "Folder contains a Dev Container... Reopen in Container?"
    *   Click "Reopen in Container".
4.  **You're In!**
    *   VS Code will read your `devcontainer.json`, which points to your `docker-compose.yml`.
    *   It will start the `gem5-dev:v1` container and connect to it.
    *   **Crucially**: Your VS Code file explorer and terminal will automatically open in `/app/garnet-web-visualizer` (as defined in `workspaceFolder`).
    *   Your local `garnet-web-visualizer` and `my-gem5-fork` folders are now "fused" with the container. Any change you save on your host is instantly reflected.
    *   The original pre-compiled gem5 project is at `/app/gem5-22.1.0.0`.
    *   Type `gemini --version` in the terminal to confirm `gemini-cli` is working.

## Step 3: How to "Update" and "Backup" (Snapshotting)

**Scenario**: You've made a critical change to the gem5 build (e.g., in your mounted `/app/my-gem5-fork`) and re-compiled it. You want to save this new compiled state.

1.  **Keep the Container Running.**
2.  **Open a separate HOST terminal** (not the VS Code one).
3.  **Commit the Container's State**:
    *   The container name is `gem5-dev-container` (set in your `docker-compose.yml`).
    *   Use `docker commit` to save the container's state as a new image.

    ```bash
    # Usage: docker commit <container-name> <new-image-tag>
    docker commit gem5-dev-container gem5-dev:v2-my-fix
    ```
4.  **You're Done!**
    *   You now have two images:
        *   `gem5-dev:v1` (your original base)
        *   `gem5-dev:v2-my-fix` (your new "backup" snapshot)
    *   You can now exit VS Code (which stops the container).
    *   The next time you want to work from this new snapshot, just update your `docker-compose.yml` to point to the new image tag:

    ```yaml
    services:
      dev:
        # build: .
        image: gem5-dev:v2-my-fix
    ...
    ```
