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

# wipe partition/filesystem info from lvm
cephadm shell -- bash -c "
ceph-volume lvm zap /dev/vg-0/lv-0
ceph-volume lvm zap /dev/vg-1/lv-1
ceph-volume lvm zap /dev/vg-2/lv-2
" || true

# add osds
ceph orch daemon add osd `hostname`:/dev/vg-0/lv-0
ceph orch daemon add osd `hostname`:/dev/vg-1/lv-1
ceph orch daemon add osd `hostname`:/dev/vg-2/lv-2
