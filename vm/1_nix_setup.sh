#!/usr/bin/env bash


# the only that needs to be done in vm window:
passwd root # -> set simple pw

ssh-keygen -f "/home/fmaurer/.ssh/known_hosts" -R "[localhost]:5555"; ssh -p 5555 root@localhost

## one-liner for creating partition
# parted /dev/sda mklabel msdos mkpart primary ext4 1MiB 100% set 1 boot on

## one-liner for formatting etc.
# mkfs.ext4 /dev/sda1 && mount /dev/sda1 /mnt && nixos-generate-config --root /mnt

# 1st all-in-one-liner:
parted -s /dev/sda mklabel msdos mkpart primary ext4 1MiB 100% set 1 boot on && \
mkfs.ext4 /dev/sda1 && mount /dev/sda1 /mnt && nixos-generate-config --root /mnt

# rsync configuration.nix to vm
rsync -vaz ./vm-conf.nix -e "ssh -p 5555" root@localhost:/mnt/etc/nixos/configuration.nix

# then on vm
nixos-install
shutdown -h now
