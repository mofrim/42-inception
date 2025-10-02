#!/usr/bin/env bash
# wget https://channels.nixos.org/nixos-25.05/latest-nixos-minimal-x86_64-linux.iso
# qemu-img create -f qcow2 nixos.qcow2 10G
qemu-system-x86_64 \
  -enable-kvm \
  -m 2G \
  -smp 2 \
  -drive file=nixos.qcow2,format=qcow2 \
	-device e1000,netdev=net0 \
	-netdev user,id=net0,hostfwd=tcp::4443-:443,hostfwd=tcp::5555-:22

# copy files over
# rsync -vaz ./bla.tar.gz -e "ssh -p 5555" fmaurer@localhost:~/
