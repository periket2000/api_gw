# Image for running git projects in python
#
FROM alpine:3.4

# install dependencies
RUN apk update \
    && apk add gcc tar libtool zlib jemalloc jemalloc-dev perl \ 
    make musl-dev openssl-dev pcre-dev g++ zlib-dev curl python3 \
    perl-test-longstring perl-list-moreutils perl-http-message \
    geoip-dev sudo

# openresty build
ENV OPENRESTY_VERSION=1.9.7.3 \
    PCRE_VERSION=8.37 \
    _prefix=/usr/local \
    _exec_prefix=/usr/local \
    _localstatedir=/var \
    _sysconfdir=/etc \
    _sbindir=/usr/local/sbin

RUN  echo "        - building regular version of the api-gateway ... " \
     && mkdir -p /tmp/nginx \
     && readonly NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
     && echo "using up to $NPROC threads" \
     && cd /tmp/nginx/ \
     && curl -k -L http://downloads.sourceforge.net/project/pcre/pcre/${PCRE_VERSION}/pcre-${PCRE_VERSION}.tar.gz -o /tmp/nginx/pcre-${PCRE_VERSION}.tar.gz \
     && curl -k -L https://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz -o /tmp/nginx/openresty-${OPENRESTY_VERSION}.tar.gz \
     && tar -zxf ./pcre-${PCRE_VERSION}.tar.gz \
     && tar -zxf ./openresty-${OPENRESTY_VERSION}.tar.gz \
     && cd /tmp/nginx/openresty-${OPENRESTY_VERSION} \
     && ./configure \
            --prefix=${_exec_prefix}/nginx \
            --sbin-path=${_sbindir}/nginx \
            --conf-path=${_sysconfdir}/nginx/api-gateway.conf \
            --error-log-path=${_localstatedir}/log/api-gateway/error.log \
            --http-log-path=${_localstatedir}/log/api-gateway/access.log \
            --pid-path=${_localstatedir}/run/api-gateway.pid \
            --lock-path=${_localstatedir}/run/api-gateway.lock \
            --with-pcre=../pcre-${PCRE_VERSION}/ --with-pcre-jit \
            --with-stream \
            --with-stream_ssl_module \
            --with-http_ssl_module \
            --with-http_stub_status_module \
            --with-http_realip_module \
            --with-http_addition_module \
            --with-http_sub_module \
            --with-http_dav_module \
            --with-http_geoip_module \
            --with-http_gunzip_module  \
            --with-http_gzip_static_module \
            --with-http_auth_request_module \
            --with-http_random_index_module \
            --with-http_secure_link_module \
            --with-http_degradation_module \
            --with-http_auth_request_module  \
            --with-http_v2_module \
            --with-luajit \
            --without-http_ssi_module \
            --without-http_userid_module \
            --without-http_uwsgi_module \
            --without-http_scgi_module \
            -j${NPROC} \
     && make -j${NPROC} \
     && make install \

# Installing python 
#
     && echo " ... installing python and git ..." \
#    && apk update \
#    && apk add python \
#    && apk add py-pip \
#    && pip install --upgrade pip
#
#    && apk add --no-cache python3 \
    && python3 -m ensurepip \
    && rm -r /usr/lib/python*/ensurepip \
    && pip3 install --upgrade pip setuptools \
    && pip3 install virtualenv \
    && apk --update add git build-base \
    && rm -r /root/.cache \
    && ln -s /usr/bin/python3 /usr/bin/python


ENV PROJECT_DIR /usr/local/pyenv
RUN mkdir -p ${PROJECT_DIR} \
    && mkdir -p /usr/local/var/www/htdocs/app

COPY init.sh ${PROJECT_DIR}/init-container.sh
COPY env.sh ${PROJECT_DIR}/env.sh
COPY scripts/* ${PROJECT_DIR}/
COPY config/api-gateway.conf /etc/nginx
COPY config/mesos.conf /etc/nginx/conf.d/

RUN adduser -S py-user -u 1000 \
    && addgroup -S py-user -g 1000 \
    && chown py-user:py-user ${PROJECT_DIR} \
    && chown py-user:py-user ${PROJECT_DIR}/*.sh \
    && chown py-user:py-user /usr/local/var/www/htdocs/app \
    && chown -R py-user:py-user /usr/lib/python* \
    && chown -R py-user:py-user /var/log/api-gateway \
    && chown -R py-user:py-user /etc/nginx \
    && chown -R py-user:py-user /usr/local/nginx \
    && chmod +x ${PROJECT_DIR}/*.sh \
    && echo "py-user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER py-user
ENTRYPOINT ${PROJECT_DIR}/init-container.sh
