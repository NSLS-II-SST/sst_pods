#! /usr/bin/bash
set -e
set -o xtrace

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

version="0.0.1"
container=$(buildah from conda-base)
buildah run $container -- pip3 install --pre databroker[all]
buildah run $container -- pip3 install bluesky
buildah run $container -- pip3 install nslsii tiled[all]
buildah run $container -- pip3 install git+https://github.com/bluesky/bluesky-adaptive.git@main#egg=bluesky-adaptive
buildah run $container -- pip3 install git+https://github.com/bluesky/bluesky-queueserver.git@main#egg=bluesky-queueserver

buildah run $container -- mkdir /etc/bluesky
buildah copy $container $script_dir/kafka.yml /etc/bluesky/kafka.yml
buildah unmount $container

buildah commit $container bluesky:latest
buildah commit $container bluesky:$version

buildah rm $container