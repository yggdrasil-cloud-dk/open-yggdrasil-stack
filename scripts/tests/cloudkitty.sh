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

cloudkitty hashmap group list -f value | grep -q instance_uptime_flavor_id || cloudkitty hashmap group create instance_uptime_flavor_id

gid=$(cloudkitty hashmap group list -f value | grep instance_uptime_flavor_id | awk '{print $2}')

cloudkitty hashmap service list -f value | grep -q instance || cloudkitty hashmap service create instance

sid=$(cloudkitty hashmap service list -f value | grep instance | awk '{print $2}')

cloudkitty hashmap field list $sid -f value | grep -q flavor_id || cloudkitty hashmap field create $sid flavor_id

fid=$(cloudkitty hashmap field list $sid -f value | grep flavor_id | awk '{print $2}')

flavor_id=$(openstack flavor show m1.tiny -f value -c id)

cloudkitty hashmap mapping create 0.01 \
 --field-id $fid \
 --value $flavor_id \
 -g $gid \
 -t flat
