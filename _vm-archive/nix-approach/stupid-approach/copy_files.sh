#!/usr/bin/env bash

set -e

initrd_file=$(cat /build/result/bin/run-nixos-vm | grep initrd | cut -d ' ' -f 6)

cp $initrd_file /output
cp -L /build/result/system/kernel /output
cp -L /build/result/system/kernel-params /output
cp -L /build/result/system/init /output
cp -L /build/result/bin/run-nixos-vm /output
