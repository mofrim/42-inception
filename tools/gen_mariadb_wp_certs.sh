#!/usr/bin/env bash

if [ -z "$INCEPTION_SHELL" ];then
  echo -e "\e[31mplz 'source <repo_root>/.inception-env first!\e[0m"
  exit 1
fi

# generating the client and server certs for mariadb and wp here

set -e
source $TOOLDIR/tools_include.sh

DAYS=365
ORG="FmaurerSoft"
OU="FmaurerIT"
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
  -subj "/O=$ORG/OU=$OU/CN=$CN_SERVER"

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
  -subj "/O=$ORG/OU=$OU/CN=$CN_CLIENT"

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
