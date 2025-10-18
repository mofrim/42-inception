#!/usr/bin/env bash

if [ -z "$INCEPTION_SHELL" ];then
  echo -e "\e[31mplz 'source <repo_root>/.inception-env first!\e[0m"
  exit 1
fi

set -e
source $TOOLDIR/tools_include.sh

DAYS=365
ORG="FmaurerSoft"
OU="FmaurerCA"
CN="FMaurerCA"

logmsg "Generating CA key and certificate..."

# gen the rootCA with all the extensions fields set required by modern browsers.
# maybe TODO: verify what is _really_ needed here
openssl req -x509 -newkey rsa:3072 -sha256 -days $DAYS \
  -nodes -keyout ca-key.pem -out ca-cert.pem \
  -subj "/O=$ORG/OU=$OU/CN=$CN" \
  -addext "keyUsage=critical,keyCertSign" \
  -addext "basicConstraints=critical,CA:TRUE,pathlen:0" \
  -addext "subjectKeyIdentifier=hash"
