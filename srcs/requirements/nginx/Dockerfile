FROM alpine:3.22

RUN apk update && apk upgrade && apk add --no-cache nginx openssl bash;

# Create directories for SSL certificates
RUN mkdir -p /etc/nginx/ssl /var/www/html;

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/server-cert.pem /etc/nginx/ssl/
COPY conf/server-key.pem /etc/nginx/ssl/

COPY ./index.html /var/www/html

RUN addgroup -g 1001 www && adduser nginx www && chown -R nginx:www /var/www/html;

EXPOSE 443

CMD ["nginx"]
