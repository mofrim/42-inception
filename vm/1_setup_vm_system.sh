#!/usr/bin/env bash

if [[ -z "$INCEP_TOOLDIR" ]];then
  echo -e "\e[31mplz 'source <repo_root>/.inception-env first!\e[0m"
  exit 1
fi

set -e
source $INCEP_TOOLDIR/tools_include.sh

if [[ "${PWD##*/}" != "vm"  ]];then
  logmsg -e "script can only be run from vm-dir."
  exit 1
fi

if [ -z "$VM_INSTALL_SHELL" ]; then
  logmsg -e "Running this script only makes sense during VM install session."
  exit 1
fi

logmsg "doing (most) setup on VM and installing system..."
echo -e "\e[37m"
ssh-keygen -f "/home/$(id -un)/.ssh/known_hosts" -R "[localhost]:5555" 
ssh -q -o StrictHostKeyChecking=no $SSH_KEYOPT -p 5555 root@localhost "parted -s /dev/sda mklabel msdos mkpart primary ext4 1MiB 100% set 1 boot on && mkfs.ext4 /dev/sda1  && mount /dev/sda1 /mnt && nixos-generate-config --root /mnt " 
rsync -vaz ./vm-conf.nix -e "ssh $SSH_KEYOPT -p 5555" root@localhost:/mnt/etc/nixos/configuration.nix 

## run nixos-install in case the image does not bring along nixpkgs package
## source.. this leads to another download step during install
#
# ssh -q -o StrictHostKeyChecking=no -p 5555 root@localhost "nix-channel -vv --update && nixos-install --no-root-password && shutdown -h now"

## nixos-install without downloading nixpkgs. requires nixpkgs sources to be present inside image.
#
ssh -q -o StrictHostKeyChecking=no $SSH_KEYOPT -p 5555 root@localhost "nixos-install --no-root-password && shutdown -h now"

echo -e "\e[0m"
