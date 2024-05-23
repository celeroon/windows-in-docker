#!/bin/bash

set -eou pipefail

export RANDOM_STR=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)

if [ ! -f Vagrantfile ]
then
    envsubst \
    '${VAGRANT_BOX},${PRIVILEGED},${INTERACTIVE},${MEMORY},${CPU},${DISK_SIZE},${RANDOM_STR}' \
    < Vagrantfile.tmp > Vagrantfile
fi

chmod 666 /dev/kvm

chown root:kvm /dev/kvm

/usr/sbin/libvirtd --daemon
/usr/sbin/virtlogd --daemon

mkdir -p /var/run/libvirt
chown -R libvirt-qemu:kvm /var/run/libvirt

mount -o remount,rw /sys
mount -o remount,rw /sys/fs/cgroup
#mount -o remount,rw /proc/sys

mkdir -p /sys/fs/cgroup/machine
chown -R libvirt-qemu:kvm /sys/fs/cgroup/machine

service dbus start

# Ensure the cgroups are mounted
mount -t tmpfs tmpfs /sys/fs/cgroup
mkdir -p /sys/fs/cgroup/machine
mount -t cgroup -o devices cgroup /sys/fs/cgroup/machine || true

VAGRANT_DEFAULT_PROVIDER=libvirt vagrant up

# Keep the container running
tail -f /dev/null
