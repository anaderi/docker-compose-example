#!/bin/sh
echo "Starting Consul Template"

exec /usr/local/bin/consul-template \
    -consul consul:8500 \
    -template "/db.conf.php.ctmpl:/var/www/html/db.conf.php"
