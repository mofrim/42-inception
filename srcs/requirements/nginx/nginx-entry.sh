#!/bin/bash
set -e

function entry_msg () {
  echo "[nginx-entry.sh] $1"
}

config_file="/etc/nginx/nginx.conf"

# the only thing we do here is sedding in the server_name AND server_port from
# env
if [[ -f $config_file ]]; then
	entry_msg "sedding in current server_name"
	sed -i "s/server_name .*;/server_name $DOMAIN_NAME;/" $config_file
	entry_msg "... and the current port"
	sed -i "s/listen [0-9]\+ ssl;/listen $NGINX_PORT ssl;/" $config_file
	sed -i "s/listen \[.*;/listen \[::\]:$NGINX_PORT ssl;/" $config_file
	entry_msg "... and the current php-fpm port"
	sed -i "s/fastcgi_pass wp.*;/fastcgi_pass wp:$PHPFPM_PORT;/" $config_file
fi

exec "$@"
