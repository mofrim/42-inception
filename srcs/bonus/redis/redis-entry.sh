#!/bin/bash
set -e

function entry_msg () {
  echo "[redis-entry.sh] $1"
}

config_file="/etc/redis/redis.conf"

if [[ -f $config_file && -n "$(grep SUPERSTRONG_PW $config_file)" ]]; then
	entry_msg "sedding in the pw"
	sed -i "s/SUPERSTRONG_PW/$REDIS_PW/" $config_file
fi

exec "$@"
