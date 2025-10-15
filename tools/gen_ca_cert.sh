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
CN_SERVER="db"
CN_CLIENT="wp"

logmsg "Generating CA key and certificate..."

openssl genrsa 4096 > ca-key.pem

openssl req -new -x509 -nodes -days $DAYS \
  -key ca-key.pem \
  -out ca-cert.pem \
  -subj "/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORG/OU=$OU/CN=$CN_CA"

