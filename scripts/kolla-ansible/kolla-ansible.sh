#!/bin/bash

# Based on https://docs.openstack.org/kolla-ansible/latest/user/quickstart.html

set -xe

# source venv
cd workspace
source kolla-venv/bin/activate

CONFIG_DIR=$(pwd)/etc/kolla
INVENTORY=$(pwd)/inventory

cd kolla-ansible/ansible/

kolla-ansible -i $INVENTORY --configdir $CONFIG_DIR $@

# # updating ceph-related packages in containers
# # TODO: build new packages in images
# docker ps | grep -o "glance_api\|nova_compute\|nova_libvirt\|cinder_volume\|cinder_backup" | xargs -I % bash -c "
#     docker exec -u 0 % bash -c \"
#         test -f /etc/apt/sources.list.d/ceph.list || (
#             echo 'deb https://download.ceph.com/debian-octopus/ focal main' > /etc/apt/sources.list.d/ceph.list
#             curl https://download.ceph.com/keys/release.asc --output release.asc
#             apt-key add release.asc
#             apt update
#             apt install -y ceph-common
#             touch /tmp/restart_container
#         )
#     \"
#     docker exec -u 0 % test -f /tmp/restart_container && docker exec -u 0 % rm -f /tmp/restart_container && docker restart % || true
# "
