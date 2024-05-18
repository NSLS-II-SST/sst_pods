#! /usr/bin/bash
set -e
set -o xtrace

LOCAL_DEV_PATH=$HOME/work/nsls-ii-sst
LOCAL_NBS_PATH=$HOME/work/xraygui
CONTAINER_DEV_PATH=/usr/local/src/nsls-ii-sst
CONTAINER_NBS_PATH=/usr/local/src/xraygui

podman run --pod acquisition \
       -dt --rm \
       --name=acq_qs \
       -v `pwd`/bluesky_config/ipython:/usr/local/share/ipython \
       -v `pwd`/bluesky_config/tiled/profiles:/etc/tiled/profiles \
       -v $LOCAL_DEV_PATH:$CONTAINER_DEV_PATH \
       -v $LOCAL_NBS_PATH:$CONTAINER_NBS_PATH \
       -e IPYTHONDIR='/usr/local/share/ipython' \
       sst:latest \
       bash

podman exec -t -w $CONTAINER_NBS_PATH/nbs_core acq_qs pip3 install -e .
podman exec -t -w $CONTAINER_DEV_PATH/sst_funcs acq_qs pip3 install -e .
podman exec -t -w $CONTAINER_DEV_PATH/sst_base acq_qs pip3 install -e .
podman exec -t -w $CONTAINER_DEV_PATH/ucal acq_qs pip3 install -e .
podman exec -t -w $CONTAINER_DEV_PATH/ucal_sim acq_qs pip3 install -e .
podman exec -t -w $CONTAINER_NBS_PATH/livetable acq_qs pip3 install -e .
podman exec -dt acq_qs start-re-manager --kafka-topic=mad.bluesky.runengine.documents \
       --kafka-server=localhost:29092 \
       --keep-re --zmq-publish-console ON \
       --use-ipython-kernel ON --startup-profile simulation
