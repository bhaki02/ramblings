#!/bin/bash

SWARM_IP=`docker run --net=host --rm racknet/ip public`
DOMAIN="local"
COMMAND=$1

rm () {
  echo "Running Cleanup"
  docker stop shipyard-rethinkdb
  docker rm shipyard-rethinkdb

  docker stop shipyard-discovery
  docker rm shipyard-discovery

  docker stop shipyard-swarm-manager
  docker rm shipyard-swarm-manager

  docker stop shipyard-swarm-agent
  docker rm shipyard-swarm-agent

  docker stop shipyard-controller
  docker rm shipyard-controller

  docker stop shipyard-proxy
  docker rm shipyard-proxy
}

install () {
  echo "Performing Install"
docker run \
    -ti \
    -d \
    -h shipyard-rethinkdb.$DOMAIN \
    --restart=always \
    --name shipyard-rethinkdb \
    rethinkdb

docker run \
    -ti \
    -d \
    -p 4001:4001 \
    -p 7001:7001 \
    --hostname shipyard-discovery.$DOMAIN \
    --restart=always \
    --name shipyard-discovery \
    microbox/etcd -name discovery

# see https://github.com/shipyard/shipyard/issues/681
docker run \
    -ti \
    -d \
    --hostname=shipyard-proxy.$DOMAIN \
    --restart=always \
    --name shipyard-proxy \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -p 2375:2375 \
    -e PORT=2375 \
    ehazlett/docker-proxy:latest

docker run \
    -ti \
    -d \
    --hostname=shipyard-swarm-manager.$DOMAIN \
    --restart=always \
    --name shipyard-swarm-manager \
    swarm:latest \
    manage --host tcp://0.0.0.0:3375 etcd://$SWARM_IP:4001


docker run \
    -ti \
    -d \
    --hostname=shipyard-swarm-manager.$DOMAIN \
    --restart=always \
    --name shipyard-swarm-agent \
    swarm:latest \
    join --addr $SWARM_IP:2375 etcd://$SWARM_IP:4001

docker run \
    -ti \
    -d \
    --restart=always \
    --name shipyard-controller \
    --link shipyard-rethinkdb:rethinkdb \
    --link shipyard-swarm-manager:swarm \
    -p 8080:8080 \
    shipyard/shipyard:latest \
    server \
    -d tcp://swarm:3375
}

if [ -z "$COMMAND" ]; then
  echo "Try the install command or rm"
elif [ $COMMAND == "install" ]; then
  install
elif [ $COMMAND == "rm" ]; then
  rm
else
  echo "Try the install command or rm"
fi
exit $?
