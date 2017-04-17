
if [ `uname -s` == "Darwin" ] ; then
  IP=`ifconfig en0 | grep 'inet ' | cut -d ' ' -f2 | awk '{ print $1}'`
else
  IP=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
fi
if [ -z "$IP" ] ; then echo "Empty $IP, exiting" ; exit ; fi
