FROM alpine:3.22

# FYI:
#  php-FPM =  HyPertext Preprocessor FastCGI (Common Gateway Infra)
#             Process Manager
# you're welcome ;) 

# this php-dependency list is highly recommended by:
# https://make.wordpress.org/hosting/handbook/server-environment/#php-extensions
# 
# *additionally*, in order to have jpeg support we *need* imagemagick-jpeg as
# the imagemagick package on alpine seems to be kept extra slim.
RUN apk update && apk upgrade && apk add --no-cache \
			php83 \
			php83-fpm \
			php83-phar \
			php83-mysqli \
			php83-curl \
			php83-dom \
			php83-exif \
			php83-fileinfo \
			php83-pecl-igbinary \
			php83-pecl-imagick \
			php83-intl \
			php83-mbstring \
			php83-openssl \
			php83-xml \
			php83-zip \
			php83-iconv \
			mariadb-client \
			imagemagick \
			imagemagick-jpeg \
			curl \
			fcgi \
			tar \
			bash \
			iproute2-ss \
			gzip;

# redis deps
RUN apk add --no-cache php83-pecl-redis php83-ctype;

# setting GID explicitly here bc we want to keep them in sync across all
# containers
RUN addgroup -g 1001 www && adduser -D -G www incept_fpm;

# download and extract WP  && set appropriate permissions. not using
# `latest.tar.gz` here for better reproducibility
RUN mkdir -p /var/www/html/wp && \
			cd /var/www/html/wp && \
			curl -O https://wordpress.org/wordpress-6.9.4.tar.gz && \
			tar -xzvf wordpress-6.9.4.tar.gz --strip-components=1 && \
			rm wordpress-6.9.4.tar.gz && \
			chown -R incept_fpm:www /var/www/html/wp && \
			chmod -R 755 /var/www/html/wp && \
			chmod -R 775 /var/www/html/wp/wp-content;

# get wp-cli
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
			chmod +x wp-cli.phar && \
			mv wp-cli.phar /usr/local/bin/wp && \
			ln -s /usr/bin/php83 /usr/local/bin/php;

RUN rm /etc/php83/php-fpm.d/www.conf;

# copy tux ;)
COPY ./my-home.html /var/www/html/wp/wp-content/themes/twentytwentyfive/templates/home.html
COPY ./tux2.png /var/www/html/wp/wp-content/themes/twentytwentyfive/assets/images/


RUN rm -rf /etc/my.cnf* && mkdir -p /etc/mysql/mariadb.conf.d/ && mkdir -p /etc/mysql/ssl;
COPY ./mariadb-client.cnf /etc/mysql/mariadb.conf.d/50-mysql-clients.cnf
COPY ./mysql/*.pem /etc/mysql/ssl/

# copy custom PHP-FPM config
COPY ./conf/php-fpm.conf /etc/php83/php-fpm.d/wordpress.conf

# create entrypoint script
COPY wp-entry.sh /wp-entry.sh
RUN chmod 700 /wp-entry.sh;
ENTRYPOINT ["/wp-entry.sh"]

COPY ping.php /ping.php
RUN chown incept_fpm:www /ping.php && chmod 700 /ping.php;

# run php-fpm in foreground
CMD ["php-fpm83", "-F"]
