#!/bin/bash

HERE=`cd $(dirname $0); pwd`

cd $HERE/frontend
make stop
cd $HERE/backend
make stop
cd $HERE/db
make stop
rm -rf mnt/*

docker stop registrator swarm-worker swarm-mgr consul
docker rm registrator swarm-worker swarm-mgr consul

