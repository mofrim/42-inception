#!/bin/bash
set -e

wp_dir="/var/www/html/wp"
#
# Generate wp-config.php if it doesn't exist
if [ ! -f "$wp_dir/wp-config.php" ] && [ -f "$wp_dir/wp-config-sample.php" ]; then
    echo "Creating wp-config.php from environment variables..."
    cp $wp_dir/wp-config-sample.php $wp_dir/wp-config.php
    
    # Replace database settings (you can use environment variables)
    sed -i "s/database_name_here/${WP_DB_NAME:-wordpress}/" $wp_dir/wp-config.php
    sed -i "s/username_here/${WP_DB_USER:-wordpress}/" $wp_dir/wp-config.php
    sed -i "s/password_here/${WP_DB_PW:-}/" $wp_dir/wp-config.php
    sed -i "s/localhost/${WP_DB_HOST:-db}/" $wp_dir/wp-config.php
	else
		echo "not editing wp-config..."
fi

if ! command -v wp; then
	echo "wp-cli not found!"
	exit 1
fi

wp_cmd="wp --path=$wp_dir"

# wp --path=/var/www/html/wp core install --path=$wp_dir --url="${DOMAIN_NAME}" --title="${SITE_TITLE}" --admin_user="admin" --admin_password="${WP_ADMIN_USER}" --admin_email="${WP_ADMIN_MAIL}"
#
# wp --path=/var/www/html/wp user create user1 user1@example.com --role=editor --user_pass="user1_password"

echo ">>>>>>> hey!"

until mariadb -h db -u ${WP_DB_USER} --password=${WP_DB_PW} -e "SELECT 1;"; do
  >&2 echo "MariaDB is unavailable - sleeping"
  sleep 1
done

if ! $wp_cmd core is-installed; then
	$wp_cmd core install --path=$wp_dir --url="${DOMAIN_NAME}" --title="${WP_SITE_TITLE}" --admin_user="admin" --admin_password="${WP_ADMIN_USER}" --admin_email="${WP_ADMIN_MAIL}"
  # $wp_cmd user create user1 user1@example.com --role=editor --user_pass="user1_password"
  # $wp_cmd user create user2 user2@example.com --role=author --user_pass="user2_password"
else
	echo "not doing this!"
fi

exec "$@"	
