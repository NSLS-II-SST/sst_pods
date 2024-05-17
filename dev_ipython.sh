#! /usr/bin/bash
set -e
set -o xtrace

IP_ADDR=`ip address show | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' | head -n 1`

LOCAL_DEV_PATH=$HOME/work/nsls-ii-sst
CONTAINER_DEV_PATH=/usr/local/src/nsls-ii-sst


podman run --pod acquisition \
       -dt --rm \
       --name=bsui \
       -v `pwd`/bluesky_config/ipython:/usr/local/share/ipython \
       -v `pwd`/bluesky_config/tiled/profiles:/etc/tiled/profiles \
       -v $LOCAL_DEV_PATH:$CONTAINER_DEV_PATH \
       -e IPYTHONDIR='/usr/local/share/ipython' \
       sst:latest \
       bash


podman exec -t -w $CONTAINER_DEV_PATH/sst_funcs bsui pip3 install -e .
podman exec -t -w $CONTAINER_DEV_PATH/sst_base bsui pip3 install -e .
podman exec -t -w $CONTAINER_DEV_PATH/ucal bsui pip3 install -e .
podman exec -t -w $CONTAINER_DEV_PATH/ucal_sim bsui pip3 install -e .
podman exec -t -w $CONTAINER_DEV_PATH/kafka_table bsui pip3 install -e .
podman exec -it bsui ipython --profile simulation
