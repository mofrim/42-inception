#!/bin/sh

# stop if any program has non-zero exit code
set -e

function entry_msg () {
  echo "[mariadb-entrypoint.sh] $1"
}

# check if mariadb data directory is empty (first run)
if [ ! -d "/var/lib/mysql/mysql" ]; then
	entry_msg "Initializing MariaDB database..."

		# install the database
		mariadb-install-db --user=mysql --datadir=/var/lib/mysql

		# start mariadb temporarily for setup
		mariadbd-safe --user=mysql --datadir=/var/lib/mysql --skip-networking \
			--no-auto-restart &

		# wait for mariadb to start. give it 10sec to do this.
		entry_msg "Waiting for MariaDB to start..."
		for i in $(seq 1 10); do
			if mariadb-admin ping >/dev/null 2>&1; then
				break
			fi
			entry_msg "MariaDB is unavailable - sleeping"
			sleep 1
		done
		if [ "$i" = 10 ]; then
			>&2 entry_msg "Uh, oh! MariaDB does not start. Giving up."
			exit 1
		fi

		entry_msg "MariaDB started successfully"

		# Set root password
		if [ -n "$MARIA_ROOT_PW" ]; then
			entry_msg "Setting root password..."
			mariadb -u root -e \
				"ALTER USER 'root'@'localhost' IDENTIFIED BY '$MARIA_ROOT_PW';"
			mariadb -u root -p"$MARIA_ROOT_PW" -e "FLUSH PRIVILEGES;"
			entry_msg "Root password set"
		else
			entry_msg "Warning: No root password set. This is not recommended for production use."
		fi

		# create database if specified
		if [ -n "$MARIA_DB" ]; then
			entry_msg "Creating database: $MARIA_DB"
			if [ -n "$MARIA_ROOT_PW" ]; then
				mariadb -u root -p"$MARIA_ROOT_PW" -e \
					"CREATE DATABASE IF NOT EXISTS \`$MARIA_DB\`;"
			else
				mariadb -u root -e "CREATE DATABASE IF NOT EXISTS \`$MARIA_DB\`;"
			fi
			entry_msg "Database created: $MARIA_DB"
		fi

		# create user if specified
		if [ -n "$MARIA_USER" ] && [ -n "$MARIA_USER_PW" ]; then
			entry_msg "Creating user: $MARIA_USER"
			if [ -n "$MARIA_ROOT_PW" ]; then
				mariadb -u root -p"$MARIA_ROOT_PW" -e \
					"CREATE USER '$MARIA_USER'@'%' IDENTIFIED BY '$MARIA_USER_PW';"
				if [ -n "$MARIA_DB" ]; then
					mariadb -u root -p"$MARIA_ROOT_PW" -e \
						"GRANT ALL PRIVILEGES ON \`$MARIA_DB\`.* TO '$MARIA_USER'@'%';"
				fi
				mariadb -u root -p"$MARIA_ROOT_PW" -e "FLUSH PRIVILEGES;"
			else
				mariadb -u root -e \
					"CREATE USER '$MARIA_USER'@'%' IDENTIFIED BY '$MARIA_USER_PW';"
				if [ -n "$MARIA_DB" ]; then
					mariadb -u root -e \
						"GRANT ALL PRIVILEGES ON \`$MARIA_DB\`.* TO '$MARIA_USER'@'%';"
				fi
				mariadb -u root -e "FLUSH PRIVILEGES;"
			fi
			entry_msg "User created: $MARIA_USER"
		fi

		# shutdown the temporary MariaDB instance gracefully
		if ! mariadb-admin -u root -p shutdown --password="$MARIA_ROOT_PW"; then
			>&2 entry_msg "MariaDB initialization process failed."
			exit 1
		fi
		entry_msg "MariaDB initialization complete"
fi

# start MariaDB with the provided arguments
entry_msg "Starting MariaDB server..."

# /etc/mysql/my.cnf is read automatically... therefore the CMD will be run as
# the user specified there
# launching CMD
exec "$@"
