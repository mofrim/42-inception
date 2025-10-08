#!/usr/bin/env bash

DAYS=365000
COUNTRY="US"
STATE="42"
CITY="42"
ORG="FMaurerIT"
OU="IT"
CN_CA="FMaurerCA"
CN_SERVER="db"
CN_CLIENT="wp"

echo "Generating CA key and certificate..."
openssl genrsa 4096 > ca-key.pem

openssl req -new -x509 -nodes -days $DAYS \
  -key ca-key.pem \
  -out ca-cert.pem \
  -subj "/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORG/OU=$OU/CN=$CN_CA"

echo "Generating server certificate..."
openssl req -newkey rsa:2048 -days $DAYS -nodes \
  -keyout server-key.pem \
  -out server-req.pem \
  -subj "/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORG/OU=$OU/CN=$CN_SERVER"

openssl rsa -in server-key.pem -out server-key.pem

openssl x509 -req -in server-req.pem -days $DAYS \
  -CA ca-cert.pem \
  -CAkey ca-key.pem \
  -set_serial 01 \
  -out server-cert.pem

echo "Generating client certificate..."
openssl req -newkey rsa:2048 -days $DAYS -nodes \
  -keyout client-key.pem \
  -out client-req.pem \
  -subj "/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORG/OU=$OU/CN=$CN_CLIENT"

openssl rsa -in client-key.pem -out client-key.pem

openssl x509 -req -in client-req.pem -days $DAYS \
  -CA ca-cert.pem \
  -CAkey ca-key.pem \
  -set_serial 02 \
  -out client-cert.pem

echo
echo "Verifying certificates..."
echo

openssl verify -CAfile ca-cert.pem server-cert.pem client-cert.pem

echo
echo "Certificate generation complete!"

rm *-req.pem
