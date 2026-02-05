#!/usr/bin/env bash

# INCEP_TOOLDIR will be set either if we are coming from a inception-shell or
# from our Makefile. Otherwise this tool cannot run.
if [[ -z "$INCEP_TOOLDIR" ]];then
  echo -e "\e[31mplz 'source <repo_root>/.inception-env first!\e[0m"
  exit 1
fi

#### check if all necessary keys and certs are there _and_ not empty ####

set -e
source $INCEP_TOOLDIR/tools_include.sh

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


