FROM ubuntu:18.04

RUN DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:maxmind/ppa && \
    apt-get update && \
    apt-get install -y \
        build-essential \
        git \
        openssl \
        perl \
        libperl-dev \
        wget \
        libgd3 \
        libgd-dev \
        libgeoip1 \
        libgeoip-dev \
        geoip-bin \
        libxml2 \
        libxml2-dev \
        libxslt1.1 \
        libxslt1-dev \
        libssl-dev && \
    \
    \
    wget https://ftp.pcre.org/pub/pcre/pcre-8.43.tar.gz  && tar xzvf pcre-8.43.tar.gz && \
    wget https://www.zlib.net/zlib-1.2.11.tar.gz && tar xzvf zlib-1.2.11.tar.gz && \
    wget https://www.openssl.org/source/openssl-1.1.1c.tar.gz && tar xzvf openssl-1.1.1c.tar.gz && \
    git clone  https://github.com/Austinb/nginx-upload-module && \
    wget https://nginx.org/download/nginx-1.16.1.tar.gz && tar zxvf nginx-1.16.1.tar.gz && \
    \
    \
    cd ./nginx-1.16.1 && \
    ./configure --prefix=/etc/nginx \
        --sbin-path=/usr/sbin/nginx \
        --modules-path=/usr/lib/nginx/modules \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --pid-path=/var/run/nginx.pid \
        --lock-path=/var/run/nginx.lock \
        --user=nginx \
        --group=nginx \
        --build=Ubuntu \
        --builddir=nginx-1.16.1 \
        --with-select_module \
        --with-poll_module \
        --with-threads \
        --with-file-aio \
        --with-http_ssl_module \
        --with-http_v2_module \
        --with-http_realip_module \
        --with-http_addition_module \
        --with-http_xslt_module=dynamic \
        --with-http_image_filter_module=dynamic \
        --with-http_geoip_module=dynamic \
        --with-http_sub_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_mp4_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_auth_request_module \
        --with-http_random_index_module \
        --with-http_secure_link_module \
        --with-http_degradation_module \
        --with-http_slice_module \
        --with-http_stub_status_module \
        --with-http_perl_module=dynamic \
        --with-perl_modules_path=/usr/share/perl/5.26.1 \
        --with-perl=/usr/bin/perl \
        --http-log-path=/var/log/nginx/access.log \
        --http-client-body-temp-path=/var/cache/nginx/client_temp \
        --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
        --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
        --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
        --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
        --with-mail=dynamic \
        --with-mail_ssl_module \
        --with-stream=dynamic \
        --with-stream_ssl_module \
        --with-stream_realip_module \
        --with-stream_geoip_module=dynamic \
        --with-stream_ssl_preread_module \
        --with-compat \
        --with-pcre=../pcre-8.43 \
        --with-pcre-jit \
        --with-zlib=../zlib-1.2.11 \
        --with-openssl=../openssl-1.1.1c \
        --with-openssl-opt=no-nextprotoneg \
        --with-debug \
        --add-module=../nginx-upload-module && \
        make && make install

RUN ln -s /usr/lib/nginx/modules /etc/nginx/modules

# Make sure that the logs are routed to console
RUN ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log

RUN mkdir -p /var/logs/nginx && \
    mkdir -p /var/cache/nginx && \
    mkdir -p /etc/nginx && \
    mkdir -p /etc/nginx/conf.d && \
    mkdir -p /tmp/uploads/1 && \
    touch /var/cache/nginx/client_temp && \
    useradd -ms /bin/bash nginx

WORKDIR /etc/nginx
COPY ./nginx.conf ./

WORKDIR /etc/nginx/conf.d
COPY ./default.conf ./

EXPOSE 80 443

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
