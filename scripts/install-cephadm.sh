#!/bin/bash

# Based on https://docs.ceph.com/en/octopus/install/ceph-deploy/quick-ceph-deploy/

set -xe

# install ceph-adm
#apt install -y cephadm

# installing like this because of bug https://tracker.ceph.com/issues/49910
cd /tmp
curl --silent --remote-name --location https://github.com/ceph/ceph/raw/pacific/src/cephadm/cephadm  
chmod +x cephadm  
sudo ./cephadm add-repo --release pacific
sudo rm /etc/apt/trusted.gpg.d/ceph.release.gpg  
wget https://download.ceph.com/keys/release.asc  
sudo apt-key add release.asc  
sudo apt update  
sudo ./cephadm install

# install ceph-common to allow host access to ceph commands
cephadm install ceph-common

# remove tmp file
rm cephadm
