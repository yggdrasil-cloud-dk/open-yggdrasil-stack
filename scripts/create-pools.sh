#!/bin/bash

# Based on https://docs.ceph.com/en/octopus/install/ceph-deploy/quick-ceph-deploy/

set -xe

# create ceph pools
ceph osd pool create volumes
ceph osd pool create images
ceph osd pool create backups
ceph osd pool create vms

# initialize pools
rbd pool init volumes
rbd pool init images
rbd pool init backups
rbd pool init vms

