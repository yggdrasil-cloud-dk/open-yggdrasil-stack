#!/bin/bash

# Based on https://docs.ceph.com/en/octopus/install/ceph-deploy/quick-ceph-deploy/

set -x

# destroy ceph
./scripts/external/cephadm-purge.sh $(ceph fsid)

# remove ceph-common
apt remove --purge -y ceph-common

# remove unused dependencies
apt autoremove

# remove repo
cephadm rm-repo
