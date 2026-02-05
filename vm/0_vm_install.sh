#!/usr/bin/env bash

set -e

if [ -z "$INCEPTION_SHELL" ]; then
  echo -e "\n\e[31mPlease 'source .inceptionenv' in repo-root firt!\e[0m"
  exit 1
fi

if [[ "${PWD##*/}" != "vm"  ]];then
  logmsg -e "script can only be run from vm-dir."
  exit 1
fi

source $INCEP_TOOLDIR/tools_include.sh

# first patch the vm-conf.nix with current users UID because we want to have
# full permissions on inception dir in VM
if [ ! -e ./vm-conf-template.nix ]; then
	logmsg -e "ERROR: ./vm-conf-template.nix not found!"
	exit 1
fi

logmsg "patching vm-conf.nix with current UID & PWs"

sed "s/uid = 42;/uid = $(id -u);/" ./vm-conf-template.nix > ./vm-conf.nix

# now patching in the real passwords, re-using my escape_sed function
if [ ! -e ./inception-vmpw ]; then
  logmsg -e "could not find inception-vmpw. copy it to vm/ dir!"
fi
sed -i "s|PW_GOES_HERE|$(escape_sed "$(cat ./inception-vmpw)")|" ./vm-conf.nix

# patching in the current active ca-cert
if [ ! -e ../secrets/ca-cert.pem ]; then
  logmsg -e "could not find ca-cert.pem! it needs to be in <repo-root>/secrets."
  exit 1
fi
logmsg "Patching in current ca-cert..."
sed -i '/CERT_GOES_HERE/r ../secrets/ca-cert.pem' ./vm-conf.nix
sed -i '/CERT_GOES_HERE/d' ./vm-conf.nix

# image_url="https://channels.nixos.org/nixos-25.05"
# nixos_image="latest-nixos-minimal-x86_64-linux.iso"

image_url="https://github.com/nix-community/nixos-images/releases/download/nixos-25.11"
nixos_image="nixos-installer-x86_64-linux.iso"

if [ ! -e $nixos_image ]; then
	logmsg "nixos-iso not found. downloading!"
	wget "$image_url/$nixos_image"
fi

if [ ! -e ./nixos.qcow2 ]; then
	logmsg "qcow image not found -> creating it!"
	qemu-img create -f qcow2 nixos.qcow2 15G
fi

logmsg "launching vm..."

qemu-system-x86_64 \
  -enable-kvm \
  -m 4G \
  -smp 2 \
  -boot d \
  -cdrom ./$nixos_image \
  -drive file=nixos.qcow2,format=qcow2 \
	-device e1000,netdev=net0 \
	-netdev user,id=net0,hostfwd=tcp::4443-:443,hostfwd=tcp::5555-:22 &

# FIXME:
# NEXT: what to do here?!?!

# did not find another way than running a new shell until the vm is completely
# set up.
#
# sleep 0.5
# clear
# logmsg "here is you todo-list for the vm:"
# echo
# print_cmds_green ./1_nix_setup.sh
# echo
# logmsg "If you feel like simply run 'killvm' to kill the VM"
# export INCEPTION_VM_PID=$!
# VM_INSTALL_SHELL="yo" bash --rcfile $inception_root/.inception-bashrc -i
# unset VM_INSTALL_SHELL

logmsg "waiting for vm to boot..."
export INCEPTION_VM_PID=$!
VM_INSTALL_SHELL="yo" bash --rcfile $inception_root/.inception-bashrc -i
unset VM_INSTALL_SHELL
# ./0a_setup_vm_system.sh

logmsg "Alrighty! Done installing & setting up the Inception VM!"

## now ssh into the vm and setup the system...
