#!/bin/bash

source util.sh
DOCKER_HOST=$IP:2375 docker info > /dev/null
if [ $? -ne 0 ]  ; then
  echo "restarting"
  docker run -p 2375:2375 --name docker-proxy \
    -v /var/run/docker.sock:/var/run/docker.sock -d -e PORT=2375 \
    shipyard/docker-proxy
else
  echo "already running"
fi

