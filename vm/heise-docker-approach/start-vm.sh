#!/usr/bin/env bash

image="./image.iso"

docker run -it --rm --name nixos \
  -e "BOOT=$image" \
  -p 8006:8006 \
  --device=/dev/kvm \
  --device=/dev/net/tun \
  --cap-add NET_ADMIN \
  -v "${PWD:-.}/nixos:/storage" \
  --stop-timeout 120 \
  qemux/qemu
