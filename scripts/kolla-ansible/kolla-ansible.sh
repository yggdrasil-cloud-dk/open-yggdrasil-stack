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
docker ps | grep -o "glance_api\|nova_compute\|nova_libvirt\|cinder_volume\|cinder_backup" | xargs -I % bash -c "
    docker exec -u 0 % bash -c \"
        test -f /etc/apt/sources.list.d/ceph.list || (
            echo 'deb https://download.ceph.com/debian-octopus/ focal main' > /etc/apt/sources.list.d/ceph.list
            curl https://download.ceph.com/keys/release.asc --output release.asc
            apt-key add release.asc
            apt update
            apt list --installed | egrep 'ceph|rbd|rados' | cut -d '/' -f 1 | xargs apt remove -y
            apt install -y librbd1=15.2.13-1focal python3-cephfs=15.2.13-1focal python3-ceph-argparse=15.2.13-1focal \
                python3-ceph-common=15.2.13-1focal python3-rados=15.2.13-1focal python3-rbd=15.2.13-1focal python3-rgw=15.2.13-1focal \
                librados2=15.2.13-1focal libcephfs2=15.2.13-1focal libradosstriper1=15.2.13-1focal librgw2=15.2.13-1focal ceph-common=15.2.13-1focal
        )
    \"
    docker restart %
"

