#!/bin/bash

# Based on https://docs.ceph.com/en/octopus/cephadm/install/

set -xe

# download cephadm
curl --silent --remote-name --location https://github.com/ceph/ceph/raw/octopus/src/cephadm/cephadm
chmod +x cephadm

# add cephadm repo to apt sources
./cephadm add-repo --version 15.2.15

# install ceph adm
./cephadm install

# delete downloaded cephadm file
rm -f cephadm

# install ceph-common
cephadm install ceph-common
