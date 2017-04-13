docker run --restart=unless-stopped -d \
    --name=registrator \
    --net=host \
    --volume=/var/run/docker.sock:/tmp/docker.sock \
    gliderlabs/registrator:latest \
    consul://`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`:8500
