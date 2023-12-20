#! /usr/bin/bash
set -e
set -o xtrace

version="0.0.1"
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
config_dir=$(dirname "$script_dir")/bluesky_config

container=$(buildah from bluesky)
buildah run $container -- pip3 install git+https://github.com/NSLS-II-SST/sst_funcs.git@reorganization
buildah run $container -- pip3 install git+https://github.com/NSLS-II-SST/sst_base.git@master
buildah run $container -- pip3 install git+https://github.com/NSLS-II-SST/ucal.git@reorganization
buildah run $container -- pip3 install git+https://github.com/NSLS-II-SST/ucal_sim.git@master
buildah copy $container $config_dir/ipython /usr/local/share/ipython
buildah copy $container $config_dir/tiled/profiles /etc/tiled/profiles
buildah unmount $container

buildah commit $container sst:latest
buildah commit $container sst:$version

buildah rm $container
