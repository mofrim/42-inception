FROM alpine:3.22

# RUN apk add --no-cache mariadb mariadb-client bash;
RUN apk add --no-cache mariadb mariadb-client bash;

# after running this there is also a user named 'mysql' and the dir
# `/var/lib/mysql` owned by this user on the system

# remove default config files and make new dir for ours
RUN rm -rf /etc/my.cnf* &&  mkdir -p /etc/mysql/ssl;
COPY my.cnf /etc/mysql
COPY mariadb.cnf /etc/mysql
COPY ./ssl/*.pem /etc/mysql/ssl/
RUN chown -R mysql:root /etc/mysql/ssl/;

# # Expose the default MariaDB port
# EXPOSE 3306
#
# # Set the volume for the database
# VOLUME ["/var/lib/mysql"]

COPY maria-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/maria-entrypoint.sh;

ENTRYPOINT ["maria-entrypoint.sh"]

# launching mariadb using `mariadbd-safe` is the recommended way for
# non-system-service use.
CMD ["mariadbd-safe"]
