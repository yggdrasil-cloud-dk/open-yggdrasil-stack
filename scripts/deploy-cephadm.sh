#!/bin/bash

# Based on https://docs.ceph.com/en/octopus/cephadm/install/

set -xe

# create ceph config directory
# TODO: maybe create in workspace dir?
mkdir -p /etc/ceph

# get mon ip address
CEPH_PUBLIC_IP=$(ifconfig ceph_public | awk '/inet / {print $2}')

# bootstrap cluster
cephadm bootstrap --mon-ip $CEPH_PUBLIC_IP

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
