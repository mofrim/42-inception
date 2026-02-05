#!/usr/bin/env bash

# INCEP_TOOLDIR will be set either if we are coming from a inception-shell or
# from our Makefile. Otherwise this tool cannot run.
if [[ -z "$INCEP_TOOLDIR" ]];then
  echo -e "\e[31mplz 'source <repo_root>/.inception-env first!\e[0m"
  exit 1
fi

set -e
source $INCEP_TOOLDIR/tools_include.sh

logmsg "now i got INCEP_TOOLDIR=$INCEP_TOOLDIR"
logmsg -e "now i got INCEP_TOOLDIR=$INCEP_TOOLDIR"
