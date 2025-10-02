#!/usr/bin/env bash



set -e

# Create an empty ext4 filesystem image. A filesystem image does not
# contain a partition table but just a filesystem.
createEmptyFilesystemImage() {
  local name=$1
  local size=$2
  local temp=$(mktemp)
  qemu-img create -f raw "$temp" "$size"
  mkfs.ext4 -L nixos "$temp"
  qemu-img convert -f raw -O qcow2 "$temp" "$name"
  rm "$temp"
}

NIX_DISK_IMAGE=$(readlink -f "${NIX_DISK_IMAGE:-./nixos.qcow2}") || test -z "$NIX_DISK_IMAGE"

if test -n "$NIX_DISK_IMAGE" && ! test -e "$NIX_DISK_IMAGE"; then
    echo "Disk image do not exist, creating the virtualisation disk image..."

    createEmptyFilesystemImage "$NIX_DISK_IMAGE" "8192M"

    echo "Virtualisation disk image created."
fi

# Create a directory for storing temporary data of the running VM.
if [ -z "$TMPDIR" ] || [ -z "$USE_TMPDIR" ]; then
    TMPDIR=$(mktemp -d nix-vm.XXXXXXXXXX --tmpdir)
fi



# Create a directory for exchanging data with the VM.
mkdir -p "$TMPDIR/xchg"
WORKDIR=$PWD







cd "$TMPDIR"



# Start QEMU.
exec qemu-system-x86_64 -machine accel=kvm:tcg -cpu max \
    -name nixos \
    -m 2048 \
    -smp 2 \
    -device virtio-rng-pci \
    -net nic,netdev=user.0,model=virtio -netdev user,id=user.0,"$QEMU_NET_OPTS" \
    -virtfs local,path=/nix/store,security_model=none,mount_tag=nix-store \
    -virtfs local,path="${SHARED_DIR:-$TMPDIR/xchg}",security_model=none,mount_tag=shared \
    -virtfs local,path="$TMPDIR"/xchg,security_model=none,mount_tag=xchg \
    -drive cache=writeback,file="$NIX_DISK_IMAGE",id=drive1,if=none,index=1,werror=report -device virtio-blk-pci,bootindex=1,drive=drive1,serial=root \
    -device virtio-keyboard \
    -usb \
    -device usb-tablet,bus=usb-bus.0 \
    -kernel ${NIXPKGS_QEMU_KERNEL_nixos_vm:-$WORKDIR/kernel} \
    -initrd $WORKDIR/initrd \
    -append "$(cat $WORKDIR/kernel-params) init=/nix/store/9rb9g37hvj51qk4v9fj6by67y0d9l2b2-nixos-system-nixos-25.05.20250910.8cd5ce8/init regInfo=/nix/store/bsnx21kpnmsglmbcn5989r4lxy0l4r48-closure-info/registration console=ttyS0,115200n8 console=tty0 $QEMU_KERNEL_PARAMS" \
    $QEMU_OPTS \
    "$@"
