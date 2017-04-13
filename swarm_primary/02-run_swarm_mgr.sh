docker run --restart=unless-stopped -d \
    --name swarm-mgr \
    -p 3375:2375 \
    swarm manage \
    --advertise `ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`:3375 \
    consul://`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`:8500/
