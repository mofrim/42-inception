#!/bin/bash
set -e

function entry_msg () {
  echo "[nginx-entry.sh] $1"
}

config_file="/etc/nginx/nginx.conf"

# the only thing we do here is sedding in the server_name from env
if [[ -f $config_file ]]; then
	entry_msg "sedding in current server_name"
	sed -i "s/server_name .*;/server_name $DOMAIN_NAME;/" $config_file
fi

exec "$@"
