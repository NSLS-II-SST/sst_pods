
#! /usr/bin/bash
set -e
set -o xtrace


container=$(buildah from sst)
buildah run $container -- pip3 install git+https://github.com/NSLS-II-SST/sim_beamline.git@master
# this is the thing you want to change to spawn your IOC
buildah config --cmd "simline --list-pvs" $container
buildah unmount $container
buildah commit $container caproto
