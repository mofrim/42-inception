#!/usr/bin/env bash

docker run -it --rm --name alpine\
	-e "BOOT=alpine" \
	-p 8006:8006 \
	--device=/dev/kvm \
	--device=/dev/net/tun \
	--cap-add NET_ADMIN \
	-v "${PWD:-.}/alpine/storage" \
	--stop-timeout 120 \
	qemux/qemu
