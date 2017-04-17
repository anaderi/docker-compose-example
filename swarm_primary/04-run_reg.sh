source util.sh

docker run --restart=unless-stopped -d \
    --name=registrator \
    --net=host \
    --volume=/var/run/docker.sock:/tmp/docker.sock \
    gliderlabs/registrator:latest \
    consul://$IP:8500
