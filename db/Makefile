BASE=${PWD}/..

run:
	docker run --name mysql-master.0 -v ${BASE}/mnt/volumes/master:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=rootpass -e MYSQL_USER=wordpress \
  -e MYSQL_PASSWORD=wordpress -e MYSQL_DATABASE=wordpress  -e REPLICATION_MASTER=true \
  -e REPLICATION_USER=replica -e REPLICATION_PASS=replica \
  --link consul:consul \
  -l "SERVICE_NAME=mysql" -l "SERVICE_PORT=3306" \
  -p 3306:3306 -d \
	mysql-master --user=root --bind-address=0.0.0.0

stop:
	docker stop mysql-master.0
	docker rm mysql-master.0

rm:
	rm -rf ${BASE}/mnt/volumes/master

build:
	docker build -t mysql-master .
