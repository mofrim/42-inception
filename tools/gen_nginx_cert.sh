#!/usr/bin/env bash

set -e
source $TOOLDIR/tools_include.sh

DAYS=365000
COUNTRY="DE"
STATE="42"
CITY="42"
ORG="FMaurerIT"
OU="IT"
CN_CA="FMaurerCA"
CN_SERVER="fmaurer.42.fr"

if [[ ! -e ./ca-key.pem || ! -e ./ca-cert.pem ]]; then
  logmsg -e "ERROR: CA certificate has to be created first!"
  exit 1
fi

logmsg "Generating Key and CSR..."
openssl req -nodes -newkey rsa:2048 \
-keyout nginx-server-key.pem -out nginx-server-req.pem \
-subj "/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORG/OU=$OU/CN=$CN_SERVER"

# generate signed cert with the CSR (cert signing request). The `set_serial` arg
# is for making the cert unique even if all other fields are the same (which
# actually isn't the case here..)
logmsg "Generating & signing the final cert.."
openssl x509 -req -in nginx-server-req.pem -days $DAYS \
  -CA ca-cert.pem \
  -CAkey ca-key.pem \
  -set_serial 03 \
  -out nginx-server-cert.pem

# remove used CSR
rm -f nginx-server-req.pem
