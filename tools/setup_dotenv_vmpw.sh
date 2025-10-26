#!/usr/bin/env bash

if [ -z "$INCEPTION_SHELL" ];then
  echo -e "\e[31mplz 'source <repo_root>/.inception-env first!\e[0m"
  exit 1
fi

set -e
source $TOOLDIR/tools_include.sh

srcdir=srcs

# TODO: test on school computers
set +e
at_school="$(hostname | grep "wolfsburg")"
set -e

if [ -n "$at_school" ]; then
  dotenv_src="~/inception-dotenv"
  vmpw_src="~/inception-vmpw"
else
  dotenv_src="../inception-dotenv"
  vmpw_src="../inception-vmpw"
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

