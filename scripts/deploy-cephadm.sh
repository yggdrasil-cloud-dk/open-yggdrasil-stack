#!/bin/bash

# Based on https://docs.ceph.com/en/octopus/install/ceph-deploy/quick-ceph-deploy/

set -xe

# create ceph config directory
# TODO: maybe create in workspace dir?
mkdir -p /etc/ceph

# prepare host packages
cephadm prepare-host

# initial config
cat <<EOF > initial-ceph.conf
[global]
osd crush chooseleaf type = 0
osd_pool_default_size = 1
osd_pool_default_min size = 1
EOF

# get mon ip address
CEPH_PUBLIC_IP=$(ifconfig ceph_public | awk '/inet / {print $2}')

# bootstrap cluster
cephadm bootstrap --config initial-ceph.conf --allow-overwrite --mon-ip $CEPH_PUBLIC_IP

# remove file
rm initial-ceph.conf

# remove partition/filesystem info from lvm
# taken from https://github.com/ceph/ceph/blob/master/src/ceph-volume/ceph_volume/devices/lvm/zap.py#L63
dd if=/dev/zero of=/dev/vg-0/lv-0 bs=1M count=10 conv=fsync
dd if=/dev/zero of=/dev/vg-1/lv-1 bs=1M count=10 conv=fsync
dd if=/dev/zero of=/dev/vg-2/lv-2 bs=1M count=10 conv=fsync

# add osds
cephadm shell -- ceph orch daemon add osd `hostname`:/dev/vg-0/lv-0
cephadm shell -- ceph orch daemon add osd `hostname`:/dev/vg-1/lv-1
cephadm shell -- ceph orch daemon add osd `hostname`:/dev/vg-2/lv-2
