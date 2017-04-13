docker run --restart=unless-stopped -d \
    --name=registrator \
    --net=host \
    --volume=/var/run/docker.sock:/tmp/docker.sock \
    gliderlabs/registrator:latest \
    -ip `ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'` \
    consul://`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`:8500
