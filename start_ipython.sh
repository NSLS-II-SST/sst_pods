#! /usr/bin/bash
set -e
set -o xtrace

IP_ADDR=`ip address show | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' | head -n 1`

podman pod create -n acquisition  -p 9092:9092/tcp \
       -p 60610:9090/tcp -p 8000:8000 -p 60615:60615 -p 60625:60625
# Caproto Simulation IOC collection
podman run -dt --pod acquisition --rm ghcr.io/nsls-ii-sst/sim_beamline:latest

# start up a mongo
podman run -dt --pod acquisition --rm docker.io/library/mongo:latest
# start up a zmq proxy
podman run --pod acquisition -dt --rm  ghcr.io/nsls-ii-sst/bluesky bluesky-0MQ-proxy 4567 5678
# set up kafka + zookeeper
podman run --pod acquisition \
       -dt --rm \
       -e ALLOW_ANONYMOUS_LOGIN=yes \
       -v /bitnami \
       docker.io/bitnami/zookeeper:3

podman run --pod acquisition \
       -dt --rm \
       --name=acq_kafka \
       -e KAFKA_CFG_ZOOKEEPER_CONNECT=localhost:2181   \
       -e ALLOW_PLAINTEXT_LISTENER=yes \
       -e KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP=PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT \
       -e KAFKA_CFG_LISTENERS=PLAINTEXT://:29092,PLAINTEXT_HOST://:9092  \
       -e KAFKA_CFG_ADVERTISED_LISTENERS=PLAINTEXT://localhost:29092,PLAINTEXT_HOST://$IP_ADDR:9092 \
       -e KAFKA_CFG_AUTO_CREATE_TOPICS_ENABLE=true \
       -v /bitnami \
       docker.io/bitnami/kafka:2

# make sure kafka is alive
sleep 2
# create the topic we are going to publish to
podman exec acq_kafka kafka-topics.sh --create --topic mad.bluesky.documents --bootstrap-server localhost:29092

# start up redis
podman run -dt --pod acquisition  --rm docker.io/redis

# start up tiled to serve data
podman run --pod acquisition \
       -dt --rm --name=tiled_server \
       -v `pwd`/bluesky_config/tiled/config:'/etc/tiled/config' \
       -e TILED_CONFIG='/etc/tiled/config' \
       ghcr.io/bluesky/databroker:latest tiled serve config --host 0.0.0.0

podman run --pod acquisition \
       -it --rm \
       --name=bsui \
       -v `pwd`/bluesky_config/ipython:/usr/local/share/ipython \
       -v `pwd`/bluesky_config/tiled/profiles:/etc/tiled/profiles \
       ghcr.io/nsls-ii-sst/sst:latest \
       bash
