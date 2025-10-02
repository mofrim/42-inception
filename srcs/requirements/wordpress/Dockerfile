FROM alpine:3.22

RUN apk update && apk upgrade && apk add --no-cache \
			php84 \
			php84-fpm \
			php84-phar \
			php84-mysqli \
			php84-iconv \ 
			mariadb-client \
			curl \
			tar \
			bash \
			gzip;

# RUN adduser -D nginx;

RUN addgroup -g 1001 www && adduser -D -G www incept_fpm;

# Download and extract WordPress
RUN mkdir -p /var/www/html/wp && \
			cd /var/www/html/wp && \
			curl -O https://wordpress.org/latest.tar.gz && \
			tar -xzvf latest.tar.gz --strip-components=1 && \
			rm latest.tar.gz && \
			chown -R incept_fpm:www /var/www/html/wp;

RUN rm /etc/php84/php-fpm.d/www.conf;

# Copy custom PHP-FPM config
COPY ./conf/php-fpm.conf /etc/php84/php-fpm.d/wordpress.conf

# TODO: continue here! wp-cli is running now. add instructions to autoconfigure
# the site
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp && \
		ln -s /usr/bin/php84 /usr/local/bin/php;

RUN rm -rf /etc/my.cnf* && mkdir -p /etc/mysql/mariadb.conf.d/ && mkdir -p /etc/mysql/ssl;
COPY ./mariadb-client.cnf /etc/mysql/mariadb.conf.d/50-mysql-clients.cnf
COPY ./mysql/*.pem /etc/mysql/ssl/

EXPOSE 9000

# Create entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod 700 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["php-fpm84", "-F"]
