#!/bin/bash

set -xe

# source venv
cd workspace
source kolla-venv/bin/activate

CONFIG_DIR=$(pwd)/etc/kolla

# source admin rc
. $CONFIG_DIR/admin-openrc.sh

image_name=$(openstack image list -f value -c Name | grep trove)

openstack image set --private  \
    --tag trove --tag postgres --tag mysql $image_name

openstack datastore version show --datastore postgresql 12.18 || openstack datastore version create 12.18 postgresql postgresql "" \
    --image-tags trove,postgres \
    --active --default

openstack database instance create postgresql_instance_1 \
    --flavor ds2G \
    --size 5 \
    --nic net-id=$(openstack network show demo-net -f value -c id) \
    --databases test --users userA:password \
    --datastore postgresql --datastore-version 12.18 \
    --replica-count 1 \
    --is-public \
    --allowed-cidr 0.0.0.0/0
