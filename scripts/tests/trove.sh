#!/bin/bash

set -xe

# source venv
cd workspace
source kolla-venv/bin/activate

CONFIG_DIR=$(pwd)/etc/kolla

# source admin rc
. $CONFIG_DIR/admin-openrc.sh

openstack image set --name trove-guest-ubuntu-focal --private  \
    --tag trove --tag mysql $(openstack image list -f value -c Name | grep trove)

openstack datastore version create 5.7.29 mysql mysql "" \
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
