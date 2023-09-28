#!/bin/bash

set -xe

# source venv
cd workspace
source kolla-venv/bin/activate
source etc/kolla/admin-openrc.sh

CONFIG_DIR=$(pwd)/etc/kolla

cloudkitty module list

cloudkitty module disable pyscripts

cloudkitty module set priority hashmap 100

# instance up time

cloudkitty hashmap group list -f value | grep -q instance_uptime_flavor_id || cloudkitty hashmap group create instance_uptime_flavor_id

gid=$(cloudkitty hashmap group list -f value | grep instance_uptime_flavor_id | awk '{print $2}')

cloudkitty hashmap service list -f value | grep -q instance || cloudkitty hashmap service create instance

sid=$(cloudkitty hashmap service list -f value | grep instance | awk '{print $2}')

cloudkitty hashmap field list $sid -f value | grep -q flavor_id || cloudkitty hashmap field create $sid flavor_id

fid=$(cloudkitty hashmap field list $sid -f value | grep flavor_id | awk '{print $2}')

flavor_id=$(openstack flavor show m1.tiny -f value -c id)

cloudkitty hashmap mapping list -g $gid -f value | grep -q $flavor_id || cloudkitty hashmap mapping create 0.01 \
 --field-id $fid \
 --value $flavor_id \
 -g $gid \
 -t flat

# volume per gb

cloudkitty hashmap group list | grep -q volume_thresholds || cloudkitty hashmap group create volume_thresholds

gid=$(cloudkitty hashmap group list -f value | grep volume_thresholds | awk '{print $2}')

cloudkitty hashmap service list | grep -q volume.size || cloudkitty hashmap service create volume.size

sid=$(cloudkitty hashmap service list -f value | grep volume.size | awk '{print $2}')

cloudkitty hashmap mapping list -g $gid -f value | grep -q $sid || cloudkitty hashmap mapping create 0.001 \
 -s $sid \
 -g $gid \
 -t flat

openstack project show test || openstack project create test

openstack user show test || openstack user create test --password test

openstack role add --user test --project test rating
openstack role add --user test --project test member
