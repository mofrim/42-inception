#!/usr/bin/env bash

# generating the client and server certs for mariadb and wp here

set -e
source $TOOLDIR/tools_include.sh

DAYS=365000
COUNTRY="US"
STATE="42"
CITY="42"
ORG="FMaurerIT"
OU="IT"
CN_CA="FMaurerCA"
CN_SERVER="db"
CN_CLIENT="wp"

if [[ ! -e ./ca-key.pem || ! -e ./ca-cert.pem ]]; then
  logmsg -e "ERROR: CA certificate has to be created first!"
  exit 1
fi

logmsg "Generating server certificate..."

# create key and signing request
openssl req -newkey rsa:2048 -nodes \
  -keyout server-key.pem \
  -out server-req.pem \
  -subj "/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORG/OU=$OU/CN=$CN_SERVER"

# generate signed cert with the CSR (cert signing request)
openssl x509 -req -in server-req.pem -days $DAYS \
  -CA ca-cert.pem \
  -CAkey ca-key.pem \
  -set_serial 01 \
  -out server-cert.pem

logmsg "Generating client certificate..."

openssl req -newkey rsa:2048 -nodes \
  -keyout client-key.pem \
  -out client-req.pem \
  -subj "/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORG/OU=$OU/CN=$CN_CLIENT"

openssl x509 -req -in client-req.pem -days $DAYS \
  -CA ca-cert.pem \
  -CAkey ca-key.pem \
  -set_serial 02 \
  -out client-cert.pem

echo
logmsg "Verifying certificates..."
echo

openssl verify -CAfile ca-cert.pem server-cert.pem client-cert.pem

echo
logmsg "Certificate generation complete!"

# remove singing request files
rm *-req.pem
