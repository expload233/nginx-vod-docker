FROM debian:bullseye-slim

ENV NGINX_VERSION 1.22.1
ENV NGINX_VOD_MODULE_VERSION 1.31
ENV NJS_VERSION     0.7.7
ENV PKG_RELEASE     1~bullseye

EXPOSE 8080

RUN apt-get update && apt-get install -y build-essential make libpcre3 libpcre3-dev  openssl libssl-dev libgd-dev zlib1g-dev openssl wget curl ca-certificates ffmpeg 

# 拉取nginx源码
RUN wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
  && tar zxf nginx-${NGINX_VERSION}.tar.gz \
  && rm nginx-${NGINX_VERSION}.tar.gz

# Get 下载vod模块.
RUN wget https://github.com/kaltura/nginx-vod-module/archive/${NGINX_VOD_MODULE_VERSION}.tar.gz \
  && tar zxf ${NGINX_VOD_MODULE_VERSION}.tar.gz \
  && rm ${NGINX_VOD_MODULE_VERSION}.tar.gz
# 编译.
RUN cd nginx-${NGINX_VERSION} \
  && ./configure \
  --prefix=/usr/local/nginx \
  --add-module=../nginx-vod-module-${NGINX_VOD_MODULE_VERSION} \
  --conf-path=/usr/local/nginx/conf/nginx.conf \
  --with-file-aio \
  --error-log-path=/opt/nginx/logs/error.log \
  --http-log-path=/opt/nginx/logs/access.log \
  --with-threads \
  --with-cc-opt="-O3" \
  --with-debug
RUN cd nginx-${NGINX_VERSION} && make && make install

#COPY nginx.conf /usr/local/nginx/conf/nginx.conf.template

# Cleanup.
RUN rm -rf /var/cache/* /tmp/*

CMD /usr/local/nginx/sbin/nginx -g 'daemon off;'