#!/bin/bash

# Based on https://docs.ceph.com/en/octopus/install/ceph-deploy/quick-ceph-deploy/

set -x

# destroy ceph
#./scripts/cephadm/external/cephadm-purge.sh $(cephadm shell -- bash -c 'ceph fsid' 2>/dev/null)
./scripts/cephadm/external/cephadm-purge.sh $(docker ps --format "{{.Names}}" | grep "ceph-.*-mon" | sed 's/ceph-//g;s/-mon.*//g')

# remove repo
cephadm rm-repo

# remove ceph-common
apt remove --purge -y ceph-common cephadm

# remove unused dependencies
apt -y autoremove