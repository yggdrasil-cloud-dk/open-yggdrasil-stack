#!/bin/bash

# Based on https://docs.openstack.org/kolla-ansible/latest/user/quickstart.html

set -xe

# source venv
cd workspace
source kolla-venv/bin/activate

CONFIG_DIR=$(pwd)/etc/kolla

kolla-ansible --configdir $CONFIG_DIR $@

# updating ceph-related packages in containers
# TODO: build new packages in images
docker ps | grep -o "glance_api\|nova_compute\|cinder_volume\|cinder_backup" | xargs -I % docker exec -u 0 % bash -c "
test -f /etc/apt/sources.list.d/ceph.list || (
  echo 'deb https://download.ceph.com/debian-pacific/ focal main' > /etc/apt/sources.list.d/ceph.list
  curl https://download.ceph.com/keys/release.asc --output release.asc
  apt-key add release.asc
  apt update
  apt install -y librados2 librbd1 python3-rados python3-rbd
)"

