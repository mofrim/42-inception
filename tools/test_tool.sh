#!/usr/bin/env bash

# exit if INCEPTION_SHELL is not set AND if we are not being called from
# Makefile (if we come from Makefile INCEP_TOOLDIR=ok will be set).
# If both are zero, someone is trying to exec this script directly or sth weird
# like this.
if [[ -z "$INCEPTION_SHELL" && -z "$INCEP_TOOLDIR" ]];then
  echo -e "\e[31mplz 'source <repo_root>/.inception-env first!\e[0m"
  exit 1
fi

set -e
source $INCEP_TOOLDIR/tools_include.sh

logmsg "now i got INCEP_TOOLDIR=$INCEP_TOOLDIR"
logmsg -e "now i got INCEP_TOOLDIR=$INCEP_TOOLDIR"
