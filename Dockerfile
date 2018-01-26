# --------------------------------------------------------
#1 BASE IMAGE AMI
# --------------------------------------------------------

FROM 	amazonlinux

# --------------------------------------------------------
#2 ENVIRONMENT VARIABLES
# --------------------------------------------------------

ENV     PHP_VERSION=56
ENV	NR_PHP_DIR=5.6
ENV     NR_INSTALL_SILENT=true
ENV	DIR_DOMAIN=dev.uprinting.com

# --------------------------------------------------------
#6 UPDATE THE SYSTEM
# --------------------------------------------------------

RUN	yum update -y

# --------------------------------------------------------
#7 INSTALL UTILS / LIBS / DEV TOOLS / COMPILER TOOLS
# --------------------------------------------------------

RUN	yum -y install \
	yum-utils \
	boost-devel \
	gcc \
        gcc-c++ \
	gperf \
	libevent-devel \ 
	libpng-devel \
	libtool \
	libuuid-devel \
	make \
	freetype-devel \
	libjpeg-turbo-devel \
	giflib-devel \
	uuid-devel \
	wget \
	zlib-devel

# --------------------------------------------------------
#8 INSTALL PHP / APACHE / EXTENSION / MODULES
# --------------------------------------------------------

RUN	yum install -y \
	httpd24 \
	httpd24-devel \
	php${PHP_VERSION} \
	php${PHP_VERSION}-devel \
	php${PHP_VERSION}-fpm \
	php${PHP_VERSION}-bcmath \ 
	php${PHP_VERSION}-dba \
	php${PHP_VERSION}-embedded \
	php${PHP_VERSION}-enchant \
	php${PHP_VERSION}-gd \
	php${PHP_VERSION}-imap \ 
	#php${PHP_VERSION}-interbase \ 
	php${PHP_VERSION}-intl \
	php${PHP_VERSION}-ldap \
	php${PHP_VERSION}-mbstring \
	php${PHP_VERSION}-mcrypt \
	php${PHP_VERSION}-mysqlnd \
	php${PHP_VERSION}-odbc \
	php${PHP_VERSION}-opcache \ 
	php${PHP_VERSION}-pdo \
	php-pear \
	php${PHP_VERSION}-pecl-apcu \ 
	php${PHP_VERSION}-pecl-imagick \ 
	php${PHP_VERSION}-pecl-memcache \
	php${PHP_VERSION}-pecl-memcached \
	php${PHP_VERSION}-pecl-redis \
	php${PHP_VERSION}-pecl-xdebug \
	php${PHP_VERSION}-pgsql \
	php${PHP_VERSION}-dbg \ 
	php${PHP_VERSION}-pspell \
	php${PHP_VERSION}-recode \
	php${PHP_VERSION}-snmp \
	php${PHP_VERSION}-soap \
	php${PHP_VERSION}-tidy \
	php${PHP_VERSION}-xmlrpc \
	mod24_fcgid \
	openssl \
	openssl-devel \
	mod24_ssl \
	libnghttp2 \
	libnghttp2-devel \
	nghttp2

# --------------------------------------------------------
#9 INSTALL GEARMAN
# --------------------------------------------------------

RUN	wget https://launchpad.net/gearmand/1.2/1.1.12/+download/gearmand-1.1.12.tar.gz && \
	tar -zxvf gearmand-1.1.12.tar.gz && \
	cd gearmand-1.1.12 && \
	./configure && \
	make && \
	make install

RUN	pecl install gearman && \
	echo -e 'extension=/usr/lib64/php/5.6/modules/gearman.so \
	\ndate.timezone="America/Los_Angeles"' >> /etc/php-5.6.ini

# --------------------------------------------------------
#11 INSTALL GEOIP
# --------------------------------------------------------

RUN	yum install -y geoip-devel && \
	pecl install geoip && \
	echo 'extension=/usr/lib64/php/5.6/modules/geoip.so' >> /etc/php-5.6.ini

# --------------------------------------------------------
#12 REWRITE CONFIGS
# --------------------------------------------------------

RUN	mkdir -p /mnt/phpcatalogs/${DIR_DOMAIN}/public && \
        echo "<?php phpinfo(); ?>" > /mnt/phpcatalogs/${DIR_DOMAIN}/public/info.php

ADD     certs/UP.crt /etc/httpd/conf/ssl.crt/UP.crt
ADD     certs/UP.key /etc/httpd/conf/ssl.key/UP.key
ADD     certs/CA.txt /etc/httpd/conf/ssl.crt/CA.txt

ADD	conf/UP3-301-rules.conf /etc/httpd/conf/rewriterules/UP3-301-rules.conf
ADD	conf/www.uprinting.com.conf /etc/httpd/conf.d/${DIR_DOMAIN}.conf

# --------------------------------------------------------
#18 SWITCH TO MPM WORKER
# --------------------------------------------------------

RUN	sed -i \
	-e '/ mpm_worker_module /s/^#//' \
	-e '/ mpm_prefork_module /s/^/#/' \
	/etc/httpd/conf.modules.d/00-mpm.conf

# --------------------------------------------------------
#19 FPM FCGID
# --------------------------------------------------------

RUN	echo "NETWORKING=yes" >/etc/sysconfig/network && \
	echo "ProxyPassMatch ^/(.*\.php(/.*)?)$ fcgi://127.0.0.1:9000/mnt/phpcatalogs/${DIR_DOMAIN}/public/$1" \
	> /etc/httpd/conf.modules.d/10-fcgid.conf

# --------------------------------------------------------
#20 SET UP NEWRELIC PHP AGENT
# --------------------------------------------------------

RUN     rpm -Uvh http://yum.newrelic.com/pub/newrelic/el5/x86_64/newrelic-repo-5-3.noarch.rpm && \
        yum -y install newrelic-php5

RUN     newrelic-install install && \
        sed -i \
        -e "s/newrelic.license =.*/newrelic.license = \${NR_INSTALL_KEY}/" \
	/etc/php-${NR_PHP_DIR}.d/newrelic.ini

# -------------------------------------------------------
#22 CREATE SHELL SCRIPT ENTRYPOINT
# -------------------------------------------------------      

RUN     echo -e '#!/bin/sh \nsh /etc/init.d/php-fpm start \
	\nsh /etc/init.d/httpd restart \
	\necho "export DOMAIN_NAME='\$DOMAIN_NAME'" >> /etc/sysconfig/httpd \
	\necho "export DOMAIN_STORE='\$DOMAIN_STORE'" >> /etc/sysconfig/httpd \
	\necho "export DOMAIN_PAYMENT='\$DOMAIN_PAYMENT'" >> /etc/sysconfig/httpd \
	\necho "export DOMAIN_DESIGN='\$DOMAIN_DESIGN'" >> /etc/sysconfig/httpd \
	\necho "export APP_SITE_ENV='\$APP_SITE_ENV'" >> /etc/sysconfig/httpd \
	\necho "export APPLICATION_ENV='\$APPLICATION_ENV'" >> /etc/sysconfig/httpd \
	\necho "export CALC_ENV='\$CALC_ENV'" >> /etc/sysconfig/httpd \
	\nexec "$@"' > start.sh && \
        chmod 755 /start.sh

# --------------------------------------------------------
#23 START UP COMMAND
# --------------------------------------------------------

CMD /start.sh /bin/bash

# --------------------------------------------------------
#END
# --------------------------------------------------------

