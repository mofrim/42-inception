FROM alpine:3.22

RUN apk update && apk upgrade && apk add --no-cache redis bash iproute2-ss;

COPY redis.conf /etc/redis/redis.conf

# create entrypoint script
COPY redis-entry.sh /redis-entry.sh
RUN chmod 700 /redis-entry.sh;
ENTRYPOINT ["/redis-entry.sh"]

CMD ["redis-server", "/etc/redis/redis.conf"]


