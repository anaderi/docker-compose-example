source util.sh
docker run --restart=unless-stopped -d \
    --name swarm-worker \
    swarm join \
    --advertise=$IP:2375 \
    consul://$IP:8500/
