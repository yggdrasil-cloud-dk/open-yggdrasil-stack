#!/bin/bash

# Based on https://docs.openstack.org/kolla-ansible/latest/user/quickstart.html

set -xe

# source venv
cd workspace
source kolla-venv/bin/activate

CONFIG_DIR=$(pwd)/etc/kolla

# source admin rc
. $CONFIG_DIR/admin-openrc.sh

# download images
wget http://download.cirros-cloud.net/0.5.1/cirros-0.5.1-x86_64-disk.img -O /tmp/cirros.img

# upload image to openstack
openstack image create --disk-format raw --container-format bare \
  --public --file /tmp/cirros.img cirros

# delete image from local
rm -rf /tmp/cirros.img
