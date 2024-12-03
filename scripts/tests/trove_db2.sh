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
    --tag trove --tag db2 --tag postgres --tag mysql $image_name

openstack keypair show --user trove testkey || openstack keypair create --public-key ~/.ssh/id_rsa.pub --user trove testkey

openstack datastore version show --datastore db2 11.5.0.0 || openstack datastore version create 11.5.0.0 db2 db2 "" \
    --image-tags trove,db2 \
    --active --default

openstack database instance create db2_instance_1 \
    --flavor ds2G \
    --size 5 \
    --nic net-id=$(openstack network show demo-net -f value -c id) \
    --databases test --users userA:password \
    --datastore db2 --datastore-version 11.5.0.0 \
    --replica-count 1 \
    --is-public \
    --allowed-cidr 0.0.0.0/0
