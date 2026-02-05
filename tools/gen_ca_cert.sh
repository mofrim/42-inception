#!/usr/bin/env bash

# exit if INCEPTION_SHELL is not set AND if we are not being called from
# Makefile (if we come from Makefile RUNNING_MAKE=ok will be set).
# If both are zero, someone is trying to exec this script directly or sth weird
# like this.
if [[ -z "$INCEPTION_SHELL" && -z "$INCEP_TOOLDIR" ]];then
  echo -e "\e[31mplz 'source <repo_root>/.inception-env first!\e[0m"
  exit 1
fi

set -e
source $INCEP_TOOLDIR/tools_include.sh

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
