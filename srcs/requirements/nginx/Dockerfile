FROM alpine:3.22

RUN apk update && apk upgrade && apk add --no-cache nginx openssl curl bash;

# Create directories for SSL certificates
RUN mkdir -p /etc/nginx/ssl /var/www/html;

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/server-cert.pem /etc/nginx/ssl/
COPY conf/server-key.pem /etc/nginx/ssl/

COPY ./index.html /var/www/html

RUN addgroup -g 1001 www && adduser nginx www \
			&& chown -R nginx:www /var/www/html;

# has no effect only here for explicitness
EXPOSE 443

# create entrypoint script
COPY nginx-entry.sh /nginx-entry.sh
RUN chmod 700 /nginx-entry.sh;
ENTRYPOINT ["/nginx-entry.sh"]

# no need to run it with `-g "daemon off;"` as we have `daemon on;` in our
# config ;)
CMD ["nginx"]
