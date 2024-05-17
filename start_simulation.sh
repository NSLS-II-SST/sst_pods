#! /usr/bin/bash
set -e
set -o xtrace

podman run -dt --pod acquisition --name simline --rm sim_beamline:latest
