FROM alpine:3.22

# client is needed for the entrypoint
RUN apk add --no-cache mariadb mariadb-client;

# after running this there is also a user named 'mysql' and the dir
# `/var/lib/mysql` owned by this user on the system

# remove default config files and make new dir for ours
RUN rm -rf /etc/my.cnf* &&  mkdir -p /etc/mysql/ssl;
COPY my.cnf /etc/mysql
COPY mariadb.cnf /etc/mysql
COPY ./ssl/*.pem /etc/mysql/ssl/
RUN chown -R mysql:root /etc/mysql/ssl/;

COPY mariadb-entrypoint.sh /mariadb-entrypoint.sh
RUN chmod 700 /mariadb-entrypoint.sh;
ENTRYPOINT ["/mariadb-entrypoint.sh"]

# launching mariadb using `mariadbd-safe` is the recommended way for
# non-system-service use.
CMD ["mariadbd-safe"]
