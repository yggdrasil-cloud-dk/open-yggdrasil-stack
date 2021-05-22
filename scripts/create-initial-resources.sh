#!/bin/bash

# Based on https://docs.openstack.org/kolla-ansible/latest/user/quickstart.html

set -xe

# source venv
cd workspace
source kolla-venv/bin/activate

CONFIG_DIR=$(pwd)/etc/kolla

# source admin rc
. $CONFIG_DIR/admin-openrc.sh

##########
# Images #
##########

test -z "$(openstack image list -f value)" && (
  # download image
  wget http://download.cirros-cloud.net/0.5.1/cirros-0.5.1-x86_64-disk.img -O /tmp/cirros.img
  # upload image to openstack
  openstack image create --disk-format raw --container-format bare \
    --public --file /tmp/cirros.img cirros --progress
  # delete image from local
  rm -rf /tmp/cirros.img
)

###########
# Flavors #
###########

test -z "$(openstack flavor list -f value)" && (
  # create flavors
  openstack flavor create --id 0 --vcpus 1 --ram 64 --disk 1 m1.nano
)

############
# Networks #
############

test -z "$(openstack network list -f value)" && (
  # create networks
  openstack network create  --share --external --provider-physical-network provider \
    --provider-network-type flat provider

