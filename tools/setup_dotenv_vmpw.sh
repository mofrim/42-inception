#!/usr/bin/env bash

set -e
source $TOOLDIR/tools_include.sh

if [ -n "$(hostname | grep "wolfsburg")" ]; then
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

logmsg "copying dotenv from $dotenv_src to src/.env!"
cp $dotenv_src src/.env
logmsg "copying vmpw from $vmpw_src to vm/inception-vmpw!"
cp $vmpw_src vm/inception-vmpw

