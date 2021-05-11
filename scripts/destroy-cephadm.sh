#!/bin/bash

# Based on https://docs.ceph.com/en/octopus/install/ceph-deploy/quick-ceph-deploy/

set -xe

# get ceph fsid
./scripts/external/cephadm-purge.sh $(ceph fsid)
