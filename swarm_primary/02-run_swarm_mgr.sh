source util.sh

docker run --restart=unless-stopped -d \
    --name swarm-mgr \
    -p 3375:2375 \
    swarm manage \
    --advertise $IP:3375 \
    consul://$IP:8500/
