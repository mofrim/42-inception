FROM alpine:3.22

# FYI:
#  php-FPM =  HyPertext Preprocessor FastCGI (Common Gateway Infra)
#             Process Manager
# you're welcome ;) 

# choosing php82 here because:
# https://make.wordpress.org/hosting/2025/04/16/wordpress-6-8-server-compatibility/

# this php-dependency list is highly recommended by:
# https://make.wordpress.org/hosting/handbook/server-environment/#php-extensions
RUN apk update && apk upgrade && apk add --no-cache \
      php82 \
      php82-fpm \
      php82-phar \
      php82-mysqli \
      php82-curl \
      php82-dom \
      php82-exif \
      php82-fileinfo \
      php82-pecl-igbinary \
      php82-pecl-imagick \
      php82-intl \
      php82-mbstring \
      php82-openssl \
      php82-xml \
      php82-zip \
      mariadb-client \
      curl \
      tar \
      bash \
      gzip;

RUN addgroup -g 1001 www && adduser -D -G www incept_fpm;

# download and extract WP  && set appropriate permissions. not using
# `latest.tar.gz` here for better reproducebility
RUN mkdir -p /var/www/html/wp && \
      cd /var/www/html/wp && \
      curl -O https://wordpress.org/wordpress-6.8.3.tar.gz && \
      tar -xzvf wordpress-6.8.3.tar.gz --strip-components=1 && \
      rm wordpress-6.8.3.tar.gz && \
      chown -R incept_fpm:www /var/www/html/wp && \
      chmod -R 755 /var/www/html/wp && \
      chmod -R 775 /var/www/html/wp/wp-content;

RUN rm /etc/php82/php-fpm.d/www.conf;

# copy custom PHP-FPM config
COPY ./conf/php-fpm.conf /etc/php82/php-fpm.d/wordpress.conf

# copy ... ;)
COPY ./my-home.html /var/www/html/wp/wp-content/themes/twentytwentyfive/templates/home.html
COPY ./tux2.png /var/www/html/wp/wp-content/themes/twentytwentyfive/assets/images/

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
      chmod +x wp-cli.phar && \
      mv wp-cli.phar /usr/local/bin/wp && \
      ln -s /usr/bin/php82 /usr/local/bin/php;

RUN rm -rf /etc/my.cnf* && mkdir -p /etc/mysql/mariadb.conf.d/ && mkdir -p /etc/mysql/ssl;
COPY ./mariadb-client.cnf /etc/mysql/mariadb.conf.d/50-mysql-clients.cnf
COPY ./mysql/*.pem /etc/mysql/ssl/

# create entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod 700 /entrypoint.sh;

ENTRYPOINT ["/entrypoint.sh"]

CMD ["php-fpm82", "-F"]
