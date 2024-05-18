#! /usr/bin/bash
set -e
set -o xtrace

LOCAL_DEV_PATH=$HOME/work/nsls-ii-sst/
NBS_DEV_PATH=$HOME/work/xraygui/

NAME=nbs-sim

podman run --pod acquisition \
       -dt \
       --name $NAME \
       -v $LOCAL_DEV_PATH:/usr/local/src/nsls-ii-sst \
       -v $NBS_DEV_PATH:/usr/local/src/xraygui \
       -v `pwd`/bluesky_config/ipython:/usr/local/share/ipython \
       nbs_sim:latest /bin/bash -c "bash /usr/local/bin/run_dev.sh; nbs-sim --startup-dir /usr/local/share/ipython/profile_simulation/startup --list-pvs"

# podman exec -t $NAME nbs-sim --profile simulation
