BASE=${PWD}/..

run:
	docker run --name fpm.0 -d -v ${BASE}/mnt/storage/www:/var/www/html \
  -e WORDPRESS_DB_NAME=wordpress -e WORDPRESS_DB_USER=wordpress -e WORDPRESS_DB_PASSWORD=wordpress \
  --link consul:consul -l "SERVICE_NAME=php-fpm" -l "SERVICE_PORT=9000" -p 9000:9000 \
fpm

build:
	docker build -t fpm .

stop:
	docker stop fpm.0
	docker rm fpm.0

rm:
	rm -rf ${BASE}/mnt/storage/www/*
