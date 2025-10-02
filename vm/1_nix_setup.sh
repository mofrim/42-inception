#!/usr/bin/env bash

passwd root # change to ssh
fdisk /dev/sda # -> create bootable new partition
mkfs.ext4 /dev/sda1 && mount /dev/sda1 /mnt && nixos-generate-config --root /mnt
rsync -vaz ./vm-conf.nix -e "ssh -p 5555" root@localhost:/mnt/etc/nixos/configuration.nix
# copy over configuration.nix
nixos-install
reboot
