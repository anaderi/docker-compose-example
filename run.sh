#!/bin/bash
set -ex

HERE=$(cd $(dirname $0) ; pwd)

function halt {
	echo $*
	exit 1
}

# check docker is listening to 2375 port
# DOCKER_HOST=tcp://:2375 docker ps

if [ ! -d $HERE/mnt ] ; then mkdir $HERE/mnt ; fi

cd $HERE/swarm_primary
./01-run_consul.sh
./02-run_swarm_mgr.sh
./03-run_swarm_wrk.sh
./04-run_reg.sh

cd $HERE/db
make build
make run
sleep 30
docker logs mysql-master.0

cd $HERE/backend
make build
make run
sleep 5
docker logs fpm.0

cd $HERE/frontend
make build
make run
docker logs balancer
echo "probably you can open http://<your host> in your browser now"