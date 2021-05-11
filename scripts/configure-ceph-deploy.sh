#!/bin/bash

# Based on https://docs.ceph.com/en/octopus/install/ceph-deploy/quick-ceph-deploy/

CEPH_RELEASE=pacific

set -xe

# add key
wget -q -O- 'https://download.ceph.com/keys/release.asc' | sudo apt-key add -

# add ceph repo
echo deb https://download.ceph.com/debian-$CEPH_RELEASE/ $(lsb_release -sc) main | sudo tee /etc/apt/sources.list.d/ceph.list

# update
apt update

# install ceph-deploy
apt install -y ceph-deploy
