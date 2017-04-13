## example on running several nodes on Docker
Running Wordpress instance on a Docker swarm cluster:
- db - mysql
- backend - wordpress engine backend
- balancer - nginx http frontend

(all scripts are borrowed from https://habrahabr.ru/company/centosadmin/blog/278939/, but fixed and tested to run on Ubuntu)