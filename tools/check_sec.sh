#!/usr/bin/env bash

#### check if all necessary keys and certs are there _and_ not empty ####

set -e
source $TOOLDIR/tools_include.sh

req_dir="src/requirements"

if [ ! -e $req_dir ]; then
  logmsg -e "cannot find $req_dir! check_sec.sh has to be called from repo root!"
  exit 1
fi


secret_files=(
  "$req_dir/mariadb/ssl/ca-cert.pem"
  "$req_dir/mariadb/ssl/server-cert.pem"
  "$req_dir/mariadb/ssl/server-key.pem"
  "$req_dir/nginx/conf/server-key.pem"
  "$req_dir/nginx/conf/server-cert.pem"
  "$req_dir/wordpress/mysql/ca-cert.pem"
  "$req_dir/wordpress/mysql/client-cert.pem"
  "$req_dir/wordpress/mysql/client-key.pem"
)

for file in "${secret_files[@]}"; do
  if [[ ! -e $file || $(stat -c %s $file) -eq 0 ]]; then
    echo "ko"
    exit
  fi
done

echo "ok"


