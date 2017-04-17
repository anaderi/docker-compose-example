BASE=${PWD}/..

run:
	docker run -p 80:80 -v ${BASE}/mnt/storage/www:/var/www/html -d --name balancer --link consul:consul \
 -l "SERVICE_NAME=balancer" -l "SERVICE_TAGS=balancer" \
 -l "SERVICE_CHECK_HTTP=/" -l "SERVICE_CHECK_INTERVAL=15s" -l "SERVICE_CHECK_TIMEOUT=1s" \
nginx-lb


build:
	docker build -t nginx-lb .


stop:
	docker stop balancer
	docker rm balancer
