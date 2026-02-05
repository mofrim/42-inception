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

srcdir=srcs

# TODO: test on school computers
set +e
at_school="$(hostname | grep "wolfsburg")"
set -e

# in school we get our secrets straight from $HOME
if [ -n "$at_school" ]; then
  dotenv_src="~/inception-dotenv"
  vmpw_src="~/inception-vmpw"
else
  dotenv_src="../inceptionSecrets/inception-dotenv"
  vmpw_src="../inceptionSecrets/inception-vmpw"
fi

if [ ! -e $dotenv_src ]; then
  logmsg -e "cannot find dotenv. plz copy it to $dotenv_src."
  exit 1
fi

if [ ! -e $vmpw_src ]; then
  logmsg -e "cannot find dotenv. plz copy it to $dotenv_src."
  exit 1
fi

logmsg "copying dotenv from $dotenv_src to $srcdir/.env!"
cp $dotenv_src $srcdir/.env
if [ $at_school ];then
  sed -i 's/^DATA_DIR.*$/DATA_DIR=\/home\/fmaurer\/data/' $srcdir/.env
fi

logmsg "copying vmpw from $vmpw_src to vm/inception-vmpw!"
cp $vmpw_src vm/inception-vmpw

