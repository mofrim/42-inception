#!/usr/bin/env bash

SHARED_DIR=/home/frido/c0de/42/theCore/16-inception/incept/vm/conf_dev/shared
nix build '.#nixosConfigurations.vm.config.system.build.vm'
SHARED_DIR=$SHARED_DIR ./result/bin/run-inception-vm-vm

