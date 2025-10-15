#!/usr/bin/env bash

## (1) the only thing that needs to be done in vm window:
passwd root # -> set simple pw

## (2) ssh to vm
ssh-keygen -f "/home/$(id -un)/.ssh/known_hosts" -R "[localhost]:5555"; ssh -o StrictHostKeyChecking=no -p 5555 root@localhost

## (3) all-in-one-liner: partition disk and generate default config
parted -s /dev/sda mklabel msdos mkpart primary ext4 1MiB 100% set 1 boot on && mkfs.ext4 /dev/sda1 && mount /dev/sda1 /mnt && nixos-generate-config --root /mnt

## (4) [on host system !!!] rsync configuration.nix to vm
rsync -vaz ./vm-conf.nix -e "ssh -p 5555" root@localhost:/mnt/etc/nixos/configuration.nix

## (5) then on vm
nixos-install --no-root-password && shutdown -h now
