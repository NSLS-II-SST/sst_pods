
#! /usr/bin/bash
set -e
set -o xtrace

version="0.0.1"
container=$(buildah from sst)
buildah run -v /home/jamie/work/beamline-simulation/sim_beamline:/usr/local/src/beamline-simulation/sim_beamline \
	--workingdir /usr/local/src/beamline-simulation/sim_beamline \
	$container -- pip3 install .
# this is the thing you want to change to spawn your IOC
buildah config --cmd "simline --list-pvs" $container
buildah unmount $container
buildah commit $container caproto:$version
buildah commit $container caproto:latest
buildah rm $container

