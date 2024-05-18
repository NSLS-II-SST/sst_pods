#! /usr/bin/bash
set -e
set -o xtrace

IP_ADDR=`ip address show | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' | head -n 1`

if [ -v "SSH_CONNECTION" ]; then
	echo "SSH_CONNECTION is set"
	# Unlike the recommendation in the linked SO post,
	# we are not using docker and thus not using docker's special network.
	# Instead, we use the IP of the host.
	IP_ADDR=`ip address show | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' | head -n 1`
	DISPLAY=`echo $DISPLAY | sed "s/^[^:]*\(.*\)/${IP_ADDR}\1/"`
fi
XAUTH=/tmp/.docker.xauth
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

# https://stackoverflow.com/questions/24112727/relative-paths-based-on-file-location-instead-of-current-working-directory
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

LOCAL_DEV_PATH=$HOME/work/nsls-ii-sst
CONTAINER_DEV_PATH=/usr/local/src/nsls-ii-sst
LOCAL_NBS_PATH=$HOME/work/xraygui
CONTAINER_NBS_PATH=/usr/local/src/xraygui

podman run --pod acquisition \
       -dt -v /tmp/.X11-unix/:/tmp/.X11-unix/ \
       -e DISPLAY \
       -v $XAUTH:$XAUTH \
       -v `pwd`/bluesky_config/bluesky:/etc/bluesky \
       -v `pwd`/bluesky_config/ipython:/usr/local/share/ipython \
       -v $LOCAL_DEV_PATH:$CONTAINER_DEV_PATH \
       -v $LOCAL_NBS_PATH:$CONTAINER_NBS_PATH \
       -e IPYTHONDIR='/usr/local/share/ipython' \
       -e XAUTHORITY=$XAUTH \
       -e XDG_RUNTIME_DIR=/tmp/runtime-$USER \
       -e EPICS_CA_ADDR_LIST=10.0.2.255 \
       -e EPICS_CA_AUTO_ADDR_LIST=no \
       --name qs-gui \
       sst_gui_dev:latest bash

podman exec -t -w /usr/local/bin qs-gui bash run_dev.sh
podman exec -t -w $CONTAINER_DEV_PATH/sst_funcs qs-gui pip3 install -e .
podman exec -t -w $CONTAINER_DEV_PATH/sst_base qs-gui pip3 install -e .
podman exec -t -w $CONTAINER_DEV_PATH/ucal qs-gui pip3 install -e .
podman exec -t -w $CONTAINER_DEV_PATH/ucal_sim qs-gui pip3 install -e .
podman exec -t qs-gui sst-gui --profile simulation
