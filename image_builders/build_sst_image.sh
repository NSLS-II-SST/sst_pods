#! /usr/bin/bash
set -e
set -o xtrace

container=$(buildah from bluesky-base)
buildah run $container -- pip3 install nslsii
buildah run $container -- pip3 install git+https://github.com/bluesky/bluesky-queueserver.git@main#egg=bluesky-queueserver
buildah run $container -- pip3 install git+https://github.com/NSLS-II-SST/sst_funcs.git@reorganization
buildah run $container -- pip3 install git+https://github.com/NSLS-II-SST/sst_base.git@master
buildah run $container -- pip3 install git+https://github.com/NSLS-II-SST/ucal.git@reorganization
buildah run $container -- pip3 install git+https://github.com/NSLS-II-SST/ucal_sim.git@master
buildah run $container -- mkdir /etc/bluesky
buildah copy $container image_builders/kafka.yml /etc/bluesky/kafka.yml
buildah unmount $container

buildah commit $container sst

buildah rm $container
