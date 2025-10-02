#!/usr/bin/env bash

nixos_image="latest-nixos-minimal-x86_64-linux.iso"

if [ ! -e $nixos_image ]; then
	echo ">> nixos-iso not found. downloading! <<"
	wget https://channels.nixos.org/nixos-25.05/$nixos_image
fi

if [ ! -e ./nixos.qcow2 ]; then
	echo ">> qcow image not found -> creating it! <<"
	qemu-img create -f qcow2 nixos.qcow2 10G
fi

echo ">> launching vm! <<"
qemu-system-x86_64 \
  -enable-kvm \
  -m 2G \
  -smp 2 \
  -boot d \
  -cdrom ./$nixos_image \
  -drive file=nixos.qcow2,format=qcow2 \
	-device e1000,netdev=net0 \
	-netdev user,id=net0,hostfwd=tcp::4443-:443,hostfwd=tcp::5555-:22

## now ssh into the vm and setup the system...
