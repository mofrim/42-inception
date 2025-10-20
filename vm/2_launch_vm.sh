#!/usr/bin/env bash


set -e
source $TOOLDIR/tools_include.sh

if [ -n "$VM_INSTALL_SHELL" ];then
  logmsg "still in VM_INSTALL_SHELL. plz hit ctrl-d to escape from shell-hell."
  exit
fi

if [[ "${PWD##*/}" != "vm"  ]];then
  logmsg -e "script can only be run from vm-dir."
  exit
fi

SHARED_DIR="./inception"
SRCDIR="../srcs"

# check if all inception files from srcs have been copied to dir shared with the
# VM. if not: do it.
if [[ ( ! -e $SHARED_DIR/requirements || ! -e $SHARED_DIR/docker-compose.yml ) \
  && -e $SRCDIR ]]
then
  logmsg "copying inception to vm-shared dir"
  rm -rf $SHARED_DIR/* && rm -f $SHARED_DIR/.env
  cp -R $SRCDIR/{*,.*} $SHARED_DIR
fi

# one last time: make sure DATA_DIR is set correctly for VM!
sed -i 's/^DATA_DIR.*$/DATA_DIR=\/home\/fmaurer\/data/' $SHARED_DIR/.env

if ask_yes_no "$(logmsg)" "do you want to launch the vm?"; then
  logmsg "launching the vm!"

  qemu-system-x86_64 \
    -enable-kvm \
    -smp 2 \
    -m 4G \
    -drive file=nixos.qcow2,format=qcow2 \
    -virtfs local,path="${SHARED_DIR}",security_model=none,mount_tag=shared \
    -device e1000,netdev=net0 \
    -netdev user,id=net0,hostfwd=tcp::4443-:443,hostfwd=tcp::5555-:22 &

  logmsg "for ssh acces run: 'ssh_to_vm'"
  export INCEPTION_VM_PID=$!
  logmsg "for killing the VM simply run 'killvm'"
  VM_RUN_SHELL="yo" bash --rcfile $inception_root/.inception-bashrc -i
  unset VM_RUN_SHELL
else
  logmsg "okay, maybe next time."
fi
echo

## manual mounting the shared folder:
# sudo mount -t 9p -o trans=virtio,msize=524288 tag_name /mount/point/on/guest
