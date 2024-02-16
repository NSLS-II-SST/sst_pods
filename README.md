# sst-pods

The `sst-pods` repository is designed to facilitate the orchestration of a comprehensive set of containers that emulate an NSLS-II beamline. The repository includes:

- Image builders for local container construction
- A `start_simulation.sh` script for initiating all images in a networked pod via Podman
- A `teardown_pods.sh` script for terminating the running pod

The most straightforward way to utilize `sst-pods` is by executing the `start_simulation.sh` script, which fetches all necessary containers from `ghcr.io`.

Currently, `sst-pods` is specifically configured to simulate the "ucal" endstation of the SST-I beamline at NSLS-II. However, future updates may extend or modify this focus.

## Building Images Locally

To build images locally, you must run the scripts in the following order:

1. `build_conda_image.sh`
2. `build_bluesky_image.sh`
3. `build_sst_image.sh`

The `build_conda_image.sh` script creates a basic Fedora container with Miniconda installed, allowing for controlled Python versioning. The `build_bluesky_image.sh` script sets up the basic Bluesky infrastructure. Finally, the `build_sst_image.sh` script installs all of the SST-I specific packages that are used for beamline control.

## Example Usage

To run the simulation, navigate to the directory containing the `start_simulation.sh` script and execute it:

```bash
cd /path/to/sst-pods
./start_simulation.sh
```

This will initiate the download of all required containers from ghcr.io (if not already present locally), and start the simulation by running all the images in a networked pod via Podman.

Upon successful execution, you should see a GUI pop up, with the simulation running in the background, emulating the operations of the "ucal" endstation of the SST-I beamline at NSLS-II.

To run the simulation, you must hit "Connect" in the Monitor Queue tab, and then "Open Environment" in the Edit and Control Queue tab. It is also helpful to load a samples file, which is currently located in "/usr/local/share/ipython/profile_simulation/startup"
