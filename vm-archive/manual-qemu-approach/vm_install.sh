#!/usr/bin/env bash
# wget https://channels.nixos.org/nixos-25.05/latest-nixos-minimal-x86_64-linux.iso
qemu-img create -f qcow2 nixos.qcow2 10G
qemu-system-x86_64 \
  -enable-kvm \
  -m 2G \
  -smp 2 \
  -boot d \
  -cdrom ./latest-nixos-minimal-x86_64-linux.iso \
  -drive file=nixos.qcow2,format=qcow2 \
	-device e1000,netdev=net0 \
	-netdev user,id=net0,hostfwd=tcp::4443-:443,hostfwd=tcp::5555-:22

	# -netdev user,id=net0,net=10.42.42.1/24,dhcpstart=10.42.42.1  \
	# -device virtio-net-pci,netdev=net0
