HERE=$(cd $(dirname $0)/.. ; pwd)

docker run --restart=unless-stopped -d -h `hostname` --name consul -v $HERE/mnt:/data  \
    -p `ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`:8300:8300 \
    -p `ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`:8301:8301 \
    -p `ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`:8301:8301/udp \
    -p `ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`:8302:8302 \
    -p `ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`:8302:8302/udp \
    -p `ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`:8400:8400 \
    -p 8500:8500 \
    -p 172.17.0.1:53:53/udp \
    gliderlabs/consul-server -server -rejoin -advertise `ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'` -bootstrap
