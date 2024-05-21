#!/bin/bash

set -xe

# source venv
cd workspace
source kolla-venv/bin/activate

CONFIG_DIR=$(pwd)/etc/kolla

# source admin rc
. $CONFIG_DIR/admin-openrc.sh

ls ~/.ssh/id_rsa || ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""
openstack keypair show testkey --user trove || openstack keypair create --user trove --public-key ~/.ssh/id_rsa.pub testkey

image_name=$(openstack image list -f value -c Name | grep trove)

openstack image set --private  \
    --tag trove --tag mysql $image_name

openstack datastore version show --datastore mysql 5.7.29 || openstack datastore version create 5.7.29 mysql mysql "" \
    --image-tags trove,mysql \
    --active --default

openstack database instance create mysql_instance_1 \
    --flavor ds2G \
    --size 5 \
    --nic net-id=$(openstack network show demo-net -f value -c id) \
    --databases test --users userA:password \
    --datastore mysql --datastore-version 5.7.29 \
    --replica-count 1 \
    --is-public \
    --allowed-cidr 0.0.0.0/0
