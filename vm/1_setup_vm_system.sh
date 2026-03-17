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

limitOut42="$INCEP_TOOLDIR/limitOut42/limitOut42"
sshCmd="ssh -q -o StrictHostKeyChecking=no $SSH_KEYOPT -p 5555 root@localhost"

logmsg 'ssh-keygen -f "/home/$(id -un)/.ssh/known_hosts" -R "[localhost]:5555"'
$limitOut42 42< <(ssh-keygen -f "/home/$(id -un)/.ssh/known_hosts" -R "[localhost]:5555")

sleep 1

logmsg ' "parted -s /dev/sda mklabel msdos mkpart primary ext4 1MiB 100% set 1 boot on"'
$limitOut42 42< <($sshCmd "parted -s /dev/sda mklabel msdos mkpart primary ext4 1MiB 100% set 1 boot on")

sleep 1

logmsg '"mkfs.ext4 /dev/sda1"'
$limitOut42 8 100000 42< <($sshCmd "mkfs.ext4 /dev/sda1 2>&1")

sleep 1

logmsg ' "mount /dev/sda1 /mnt"'
$limitOut42 42< <($sshCmd "mount /dev/sda1 /mnt 2>&1")

sleep 1

logmsg ' "nixos-generate-config --root /mnt"'
$limitOut42 42< <($sshCmd "nixos-generate-config --root /mnt")

sleep 1

logmsg 'rsync -vaz ./vm-conf.nix -e "ssh $SSH_KEYOPT -p 5555" root@localhost:/mnt/etc/nixos/configuration.nix'
$limitOut42 42< <(rsync -vaz ./vm-conf.nix -e "ssh $SSH_KEYOPT -p 5555" root@localhost:/mnt/etc/nixos/configuration.nix)

sleep 1

logmsg 'ssh -q -o StrictHostKeyChecking=no $SSH_KEYOPT -p 5555 root@localhost "nixos-install --no-root-password"'

$limitOut42 14 10000 42< <($sshCmd 'nixos-install --no-root-password 2>&1')

sleep 1

logmsg 'ssh -q -o StrictHostKeyChecking=no $SSH_KEYOPT -p 5555 root@localhost "shutdown -h now"'
$limitOut42 8 10000 42< <($sshCmd "shutdown -h now")
