#!/bin/bash
set -e

wp_dir="/var/www/html/wp"

function entry_msg () {
  echo "[wp-entrypoint.sh] $1"
}

# FIXME add more cfg here

# FIXME HTTP_HOST in functions.php not known error?!!

# FIXME http_S_://fmaurer.42.fr should be the final site-url

# FIXME fill those fields from wp-config.php:
# define( 'AUTH_KEY',         'put your unique phrase here' );
# define( 'SECURE_AUTH_KEY',  'put your unique phrase here' );
# define( 'LOGGED_IN_KEY',    'put your unique phrase here' );
# define( 'NONCE_KEY',        'put your unique phrase here' );
# define( 'AUTH_SALT',        'put your unique phrase here' );
# define( 'SECURE_AUTH_SALT', 'put your unique phrase here' );
# define( 'LOGGED_IN_SALT',   'put your unique phrase here' );
# define( 'NONCE_SALT',       'put your unique phrase here' );

# generate wp-config.php if it doesn't exist. on first-run wordpress will
# already be downloaded and extracted to $wp_dir from the corresponding step in
# Dockerfile. so all we have to do here is copy over wp-config-sample.php and
# sed-i some lines.
if [ ! -f "$wp_dir/wp-config.php" ] && [ -f "$wp_dir/wp-config-sample.php" ]; then
    entry_msg "Creating wp-config.php from environment variables..."
    cp $wp_dir/wp-config-sample.php $wp_dir/wp-config.php

    sed -i "s/database_name_here/$WP_DB_NAME/" $wp_dir/wp-config.php
    sed -i "s/username_here/$WP_DB_USER/" $wp_dir/wp-config.php
    sed -i "s/password_here/$WP_DB_PW/" $wp_dir/wp-config.php
    sed -i "s/localhost/$WP_DB_HOST/" $wp_dir/wp-config.php
  else
    entry_msg "not editing wp-config..."
fi

# if wp-config.php exists, secure it and set the right permissions!
if [ -f /var/www/html/wp/wp-config.php ]; then
    chown incept_fpm:www /var/www/html/wp/wp-config.php
    chmod 640 /var/www/html/wp/wp-config.php
fi

if ! command -v wp; then
  entry_msg "ERROR! wp-cli not found! smthing has gone wrong badly!"
  exit 1
fi


# wait for mariadb to become available
until mariadb -h db -u $WP_DB_USER --password=$WP_DB_PW -e "SELECT 1;" &> /dev/null; do
  >&2 entry_msg "MariaDB is unavailable - sleeping"
  sleep 1
done

# alias long for otherwise command
# NOTE: using `--url="${DOMAIN_NAME}` with _every_ wp-cli command to avoid
# Warning that HTTP_HOST is not set
wp_cmd="wp --path=$wp_dir --url=$DOMAIN_NAME"


if ! $wp_cmd core is-installed --url="$DOMAIN_NAME"; then
  entry_msg "setting up wordpress using wp-cli"
  $wp_cmd core install --title="$WP_SITE_TITLE" --admin_user="$WP_ADMIN_USER" \
    --admin_password="$WP_ADMIN_PW" --admin_email="$WP_ADMIN_MAIL" --skip-email
  echo "user2 mail: $WP_USER2_MAIL"
  echo "admin mail: $WP_ADMIN_MAIL"
  $wp_cmd user create "$WP_USER2" "$WP_USER2_MAIL" --role=editor \
    --user_pass="$WP_USER2_PW"
else
  entry_msg "alrighty, wp is already setup. nothing to do here."
fi

# ensure wp-content directories exist
mkdir -p /var/www/html/wp/wp-content/uploads
mkdir -p /var/www/html/wp/wp-content/upgrade

# fix ownership - CRITICAL for WordPress to write files!!!
chown -R incept_fpm:www /var/www/html/wp/wp-content
chmod -R 775 /var/www/html/wp/wp-content

# fix permissions to log-dir so that we can run php-fpm with lesser priveleges
mkdir -p /var/log/php82
chown incept_fpm:www /var/log/php82
chmod 755 /var/log/php82  # Ensure directory is readable/executable by all

entry_msg "finally, launching php-fpm for serving wp to nginx"

# NOTE:
# the php-fpm server is launching a master process which is running as root but
# as specified by the in php-fpm.conf the processes serving our WP will run as
# incept_fpm:www. if it wasn't like this we could launch the CMD using
#
#   exec su-exec incept_fpm "$@"
#
# which which would fix the problem of having to run the entrypoint as root but
# wanting to launch the CMD as non-root.

exec "$@"
