#!/usr/bin/env bash

nixos_image="latest-nixos-minimal-x86_64-linux.iso"

# first patch the vm-conf.nix with fmaurer@42's uid:
if [ ! -e ./vm-conf.nix ]; then
	echo ">> ERROR: ./vm-conf.nix not found! <<"
	exit 1
fi
if [ -n "$(grep "uid = 42" ./vm-conf.nix)" ]; then
	echo ">> patching vm-conf.nix with current uid <<"
	sed -i "s/uid = 42;/uid = $(id -u);/" ./vm-conf.nix
else
	echo ">> patching vm-conf.nix is already done. <<"
fi

if [ ! -e $nixos_image ]; then
	echo ">> nixos-iso not found. downloading! <<"
	wget https://channels.nixos.org/nixos-25.05/$nixos_image
fi

if [ ! -e ./nixos.qcow2 ]; then
	echo ">> qcow image not found -> creating it! <<"
	qemu-img create -f qcow2 nixos.qcow2 15G
fi

echo ">> launching vm! <<"
qemu-system-x86_64 \
  -enable-kvm \
  -m 4G \
  -smp 2 \
  -boot d \
  -cdrom ./$nixos_image \
  -drive file=nixos.qcow2,format=qcow2 \
	-device e1000,netdev=net0 \
	-netdev user,id=net0,hostfwd=tcp::4443-:443,hostfwd=tcp::5555-:22

## now ssh into the vm and setup the system...
