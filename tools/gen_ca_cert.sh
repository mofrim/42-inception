#!/usr/bin/env bash

if [ -z "$INCEPTION_SHELL" ];then
  echo -e "\e[31mplz 'source <repo_root>/.inception-env first!\e[0m"
  exit 1
fi

set -e
source $TOOLDIR/tools_include.sh

DAYS=365
COUNTRY="DE"
STATE="42"
CITY="42"
ORG="FMaurerIT"
OU="IT"
CN_CA="FMaurerCA"

logmsg "Generating CA key and certificate..."

openssl genrsa 4096 > ca-key.pem

openssl req -new -x509 -nodes -days $DAYS \
  -key ca-key.pem \
  -out ca-cert.pem \
  -subj "/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORG/OU=$OU/CN=$CN_CA"
