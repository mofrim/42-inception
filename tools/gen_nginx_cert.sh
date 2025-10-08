#!/usr/bin/env bash

DAYS=365000
COUNTRY="US"
STATE="42"
CITY="42"
ORG="FMaurerIT"
OU="IT"
CN_CA="FMaurerCA"
CN_SERVER="fmaurer.42.fr"

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout server.key -out server.crt -subj \
"/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORG/OU=$OU/CN=$CN_SERVER"
