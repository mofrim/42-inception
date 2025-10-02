#!/usr/bin/env bash

passwd root # change to ssh
fdisk /dev/sda # -> create bootable new partition
mkfs.ext4 /dev/sda1 && mount /dev/sda1 /mnt && nixos-generate-config --root /mnt
# copy over configuration.nix
nixos-install
reboot
