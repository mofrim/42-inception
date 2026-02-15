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

image_url="https://github.com/nix-community/nixos-images/releases/download/nixos-25.05"
nixos_image="nixos-installer-x86_64-linux.iso"

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

# yes, ehm, a little over-engineered wait-for-install-vm-to-be-ready handling
first_loop=1
while ! ssh -q -o StrictHostKeyChecking=no -o ConnectTimeout=1 -o BatchMode=yes -i ~/.ssh/id_ed25519-mofrim -p 5555 root@localhost echo "yo" > /dev/null; do
	if [ $first_loop -eq 1 ]; then
		logmsg "VM not yet available...   "
		logmsg -n	"...waiting -> "
		trap spinner_cleanup EXIT
		spinner &
		SPINNER_PID=$!
		first_loop=0
	fi
	sleep 1
done

# stop spinner
spinner_cleanup

# and start vm system setup
echo
logmsg "VM available!"
VM_INSTALL_SHELL="yo" ./0a_setup_vm_system.sh

logmsg "Alrighty! Done installing & setting up the Inception VM!"
