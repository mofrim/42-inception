#!/usr/bin/env bash

set -e
source $TOOLDIR/tools_include.sh

SHARED_DIR="./inception"

if ask_yes_no "do you want to launch the vm?" "y"; then
  qemu-system-x86_64 \
    -enable-kvm \
    -smp 2 \
    -m 4G \
    -drive file=nixos.qcow2,format=qcow2 \
    -virtfs local,path="${SHARED_DIR}",security_model=none,mount_tag=shared \
    -device e1000,netdev=net0 \
    -netdev user,id=net0,hostfwd=tcp::4443-:443,hostfwd=tcp::5555-:22
else
  logmsg "okay, maybe next time."
fi

# ssh-keygen -f "/home/$(id -un)/.ssh/known_hosts" -R "[localhost]:5555"; ssh -o StrictHostKeyChecking=no -p 5555 fmaurer@localhost

## manual mounting the shared folder:
# sudo mount -t 9p -o trans=virtio,msize=524288 tag_name /mount/point/on/guest
