#!/usr/bin/env bash

nixos_image="latest-nixos-minimal-x86_64-linux.iso"

# first patch the vm-conf.nix with current users UID because we want to have
# full permissions on inception dir in VM
if [ ! -e ./vm-conf-template.nix ]; then
	echo ">> ERROR: ./vm-conf-template.nix not found! <<"
	exit 1
fi

echo ">> patching vm-conf.nix with current UID & PWs <<"
sed "s/uid = 42;/uid = $(id -u);/" ./vm-conf-template.nix > ./vm-conf.nix

# now patching in the real passwords, re-using my escape_sed function
function escape_sed() {
  echo "$1" | sed 's/[][}{}^/()$&.*+?|]/\\&/g'
}
sed -i "s|PW_GOES_HERE|$(escape_sed "$(cat ./inception_vm_pw)")|" ./vm-conf.nix

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
