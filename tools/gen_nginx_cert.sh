#!/usr/bin/env bash

if [ -z "$INCEPTION_SHELL" ];then
  echo -e "\e[31mplz 'source <repo_root>/.inception-env first!\e[0m"
  exit 1
fi

set -e
source $TOOLDIR/tools_include.sh

DAYS=365
ORG="FMaurerSoft"
OU="FmaurerIT"
CN="fmaurer.42.fr"

if [[ ! -e ./ca-key.pem || ! -e ./ca-cert.pem ]]; then
  logmsg -e "ERROR: CA certificate has to be created first!"
  exit 1
fi

logmsg "Generating Key and CSR..."

openssl req -nodes -newkey rsa:3072 \
-keyout nginx-server-key.pem -out nginx-server-req.csr \
-subj "/O=$ORG/OU=$OU/CN=$CN"

# generate signed cert with the CSR (cert signing request). The `set_serial` arg
# is for making the cert unique even if all other fields are the same (which
# actually isn't the case here..)
logmsg "Generating & signing the final cert.."

openssl x509 -req -in nginx-server-req.csr -CA ca-cert.pem -CAkey ca-key.pem \
  -CAcreateserial -out nginx-server-cert.pem -days 365 -sha256 \
  -extfile <(cat <<EOF
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = DNS:fmaurer.42.fr
EOF
)

# remove used CSR
rm -f nginx-server-req.csr
