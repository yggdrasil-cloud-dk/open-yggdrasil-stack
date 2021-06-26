#!/bin/bash

# Based on https://docs.ceph.com/en/octopus/install/ceph-deploy/quick-ceph-deploy/

set -x

# destroy ceph
./scripts/external/cephadm-purge.sh $(cephadm shell -- bash -c 'ceph fsid' 2>/dev/null)

# remove ceph-common
apt remove --purge -y ceph-common

# remove unused dependencies
apt -y autoremove

# remove repo
cephadm rm-repo