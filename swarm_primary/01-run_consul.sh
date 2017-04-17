#!/bin/bash
HERE=$(cd $(dirname $0) ; pwd)

source $HERE/util.sh

if [ -z "$IP" ] ; then echo "No IP specified" ; exit 1; fi

docker run --restart=unless-stopped -d -h `hostname` --name consul -v $HERE/../mnt:/data  \
    -p 8300:8300 \
    -p 8301:8301 \
    -p 8301:8301/udp \
    -p 8302:8302 \
    -p 8302:8302/udp \
    -p 8400:8400 \
    -p 8500:8500 \
    gliderlabs/consul-server:0.6 -server -rejoin -advertise $IP -bootstrap 

#    -p 172.17.0.1:53:53/udp \
