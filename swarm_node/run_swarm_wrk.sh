docker run --restart=unless-stopped -d \
    swarm join \
    --advertise=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`:2375 \
    consul://`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`:8500/
