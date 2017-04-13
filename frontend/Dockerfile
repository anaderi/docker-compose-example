FROM phusion/baseimage:0.9.18

ENV NGINX_VERSION 1.8.1-1~trusty

ENV DEBIAN_FRONTEND=noninteractive

# Avoid ERROR: invoke-rc.d: policy-rc.d denied execution of start.
RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d

RUN curl -sS http://nginx.org/keys/nginx_signing.key | sudo apt-key add - && \
    echo 'deb http://nginx.org/packages/ubuntu/ trusty nginx' >> /etc/apt/sources.list && \
    echo 'deb-src http://nginx.org/packages/ubuntu/ trusty nginx' >> /etc/apt/sources.list && \
    apt-get update -qq && apt-get install -y unzip ca-certificates nginx=${NGINX_VERSION} && \
    rm -rf /var/lib/apt/lists/* && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80

# Скачиваем и распаковываем последнюю версию Consul Template
ADD https://releases.hashicorp.com/consul-template/0.12.2/consul-template_0.12.2_linux_amd64.zip /usr/bin/
RUN unzip /usr/bin/consul-template_0.12.2_linux_amd64.zip -d /usr/local/bin

ADD nginx.service /etc/service/nginx/run
RUN chmod a+x /etc/service/nginx/run
ADD consul-template.service /etc/service/consul-template/run
RUN chmod a+x /etc/service/consul-template/run

RUN rm -v /etc/nginx/conf.d/*.conf
ADD app.conf.ctmpl /etc/consul-templates/app.conf.ctmpl


CMD ["/sbin/my_init"]
