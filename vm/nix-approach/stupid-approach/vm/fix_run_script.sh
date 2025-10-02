#!/usr/bin/env bash

## the sed-instrcution to rule them all!
#
# 		-e '/^/s/^.*$//'

cat ./run-nixos-vm | \
	sed \
	-e '/^mkdir/a WORKDIR=\$PWD' \
	-e '/^#!/s/^.*$/#!\/usr\/bin\/env bash/'\
	-e '/export/s/^.*$//' \
	-e '/qemu-img create/s/^.*$/  qemu-img create -f raw "\$temp" "\$size"/' \
	-e '/mkfs\.ext4/s/^.*$/  mkfs.ext4 -L nixos "\$temp"/'\
	-e '/qemu-img convert/s/^.*$/  qemu-img convert -f raw -O qcow2 "\$temp" "\$name"/'\
	-e '/^exec/s/\/nix\/store\/.*\/bin\///'\
	-e '/^\s\+-kernel/s/^.*$/    -kernel \${NIXPKGS_QEMU_KERNEL_nixos_vm:-\$WORKDIR\/kernel} \\/' \
	-e '/^\s\+-initrd/s/^.*$/    -initrd \$WORKDIR\/initrd \\/' \
	-e '/^\s\+-append/s/(.*)/(cat \$WORKDIR\/kernel-params)/' \
	> run-vm-fixed.sh

chmod +x run-vm-fixed.sh

