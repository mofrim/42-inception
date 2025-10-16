#!/usr/bin/env bash

if [ -z "$INCEPTION_SHELL" ];then
  echo -e "\e[31mplz 'source <repo_root>/.inception-env first!\e[0m"
  exit 1
fi

set -e
source $TOOLDIR/tools_include.sh

logmsg "now i got TOOLDIR=$TOOLDIR"
logmsg -e "now i got TOOLDIR=$TOOLDIR"
