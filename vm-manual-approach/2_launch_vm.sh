#!/usr/bin/env bash

SHARED_DIR="./inception"

qemu-system-x86_64 \
	-enable-kvm \
  -smp 2 \
  -m 4G \
  -drive file=nixos.qcow2,format=qcow2 \
	-virtfs local,path="${SHARED_DIR}",security_model=none,mount_tag=shared \
	-device e1000,netdev=net0 \
	-netdev user,id=net0,hostfwd=tcp::4443-:443,hostfwd=tcp::5555-:22

## manual mounting the shared folder:
# sudo mount -t 9p -o trans=virtio,msize=524288 tag_name /mount/point/on/guest

# or copy files over via rsync:
# rsync -vaz ./bla.tar.gz -e "ssh -p 5555" fmaurer@localhost:~/
