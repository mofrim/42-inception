#!/bin/sh

# stop if any program has non-zero exit code, even in pipelines
set -eo pipefail

# Check if MariaDB data directory is empty (first run)
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB database..."
    
    # Install the database
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
    
    # Start MariaDB temporarily for setup
    mariadbd-safe --user=mysql --datadir=/var/lib/mysql --skip-networking &
    pid="$!"
    
    # Wait for MariaDB to start
    echo "Waiting for MariaDB to start..."
    for i in {30..0}; do
        if mariadb-admin ping >/dev/null 2>&1; then
            break
        fi
        echo "MariaDB is unavailable - sleeping"
        sleep 1
    done
    
    if [ "$i" = 0 ]; then
        echo >&2 "MariaDB did not start"
        exit 1
    fi
    
    echo "MariaDB started successfully"
    
    # Set root password
    if [ -n "$MARIA_ROOT_PW" ]; then
        echo "Setting root password..."
        mariadb -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MARIA_ROOT_PW';"
        mariadb -u root -p"$MARIA_ROOT_PW" -e "FLUSH PRIVILEGES;"
        echo "Root password set"
    else
        echo "Warning: No root password set. This is not recommended for production use."
    fi
    
    # Create database if specified
    if [ -n "$MARIA_DB" ]; then
        echo "Creating database: $MARIA_DB"
        if [ -n "$MARIA_ROOT_PW" ]; then
            mariadb -u root -p"$MARIA_ROOT_PW" -e "CREATE DATABASE IF NOT EXISTS \`$MARIA_DB\`;"
        else
            mariadb -u root -e "CREATE DATABASE IF NOT EXISTS \`$MARIA_DB\`;"
        fi
        echo "Database created: $MARIA_DB"
    fi
    
    # Create user if specified
    if [ -n "$MARIA_USER" ] && [ -n "$MARIA_USER_PW" ]; then
        echo "Creating user: $MARIA_USER"
        if [ -n "$MARIA_ROOT_PW" ]; then
            mariadb -u root -p"$MARIA_ROOT_PW" -e "CREATE USER '$MARIA_USER'@'%' IDENTIFIED BY '$MARIA_USER_PW';"
            if [ -n "$MARIA_DB" ]; then
                mariadb -u root -p"$MARIA_ROOT_PW" -e "GRANT ALL PRIVILEGES ON \`$MARIA_DB\`.* TO '$MARIA_USER'@'%';"
            fi
            mariadb -u root -p"$MARIA_ROOT_PW" -e "FLUSH PRIVILEGES;"
        else
            mariadb -u root -e "CREATE USER '$MARIA_USER'@'%' IDENTIFIED BY '$MARIA_USER_PW';"
            if [ -n "$MARIA_DB" ]; then
                mariadb -u root -e "GRANT ALL PRIVILEGES ON \`$MARIA_DB\`.* TO '$MARIA_USER'@'%';"
            fi
            mariadb -u root -e "FLUSH PRIVILEGES;"
        fi
        echo "User created: $MARIA_USER"
    fi
    
    # Stop the temporary MariaDB instance
    if ! kill -s TERM "$pid" || ! wait "$pid"; then
        echo >&2 "MariaDB initialization process failed."
        exit 1
    fi
    
    echo "MariaDB initialization complete"
fi

# Configure MariaDB to accept connections from any IP

# Start MariaDB with the provided arguments
echo "Starting MariaDB server..."

# according to <link> /etc/mysql/my.cnf is read automatically
exec "$@"
