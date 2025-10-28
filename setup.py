import argparse
import os
import subprocess
import sys

def run_command(command, cwd=None):
    print(f"Running command: {' '.join(command)}")
    result = subprocess.run(command, cwd=cwd, check=True, text=True, capture_output=True)
    print(result.stdout)
    if result.stderr:
        print(result.stderr)

def main():
    parser = argparse.ArgumentParser(description="Setup ORS Development Environment.")
    parser.add_argument("--garnet-repo",
                        default="https://github.com/davin-san/garnet-web-visualizer.git",
                        help="URL for the Garnet Web Visualizer repository.")
    parser.add_argument("--gem5-repo",
                        default="https://github.com/davin-san/gem5-tracer.git",
                        help="URL for the gem5-tracer repository.")
    args = parser.parse_args()

    print("--- Setting up ORS Development Environment ---")

    script_dir = os.path.dirname(os.path.abspath(__file__))
    parent_dir = os.path.abspath(os.path.join(script_dir, os.pardir))

    # Navigate to the parent directory to clone repositories as siblings
    os.chdir(parent_dir)

    repos = {
        "garnet-web-visualizer": args.garnet_repo,
        "gem5-tracer": args.gem5_repo,
    }

    for name, url in repos.items():
        repo_path = os.path.join(parent_dir, name)
        if not os.path.isdir(repo_path):
            print(f"Cloning {name} from {url}...")
            run_command(["git", "clone", url, name])
        else:
            print(f"{name} already exists. Skipping clone.")

    # Navigate back to the ors-containers directory
    os.chdir(script_dir)

    print("Building Docker image...")
    run_command(["docker-compose", "build"])

    print("Starting Docker containers...")
    run_command(["docker-compose", "up", "-d"])

    print("--- Setup Complete! ---")
    print("You can now open the 'ors-containers' folder in VS Code and 'Reopen in Container'.")

if __name__ == "__main__":
    main()
