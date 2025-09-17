#!/bin/bash

set -x

# source venv
cd workspace
source kolla-venv/bin/activate

CONFIG_DIR=$(pwd)/etc/kolla

# source admin rc
. $CONFIG_DIR/admin-openrc.sh

openstack coe cluster list -f value -c name | xargs -r openstack coe cluster delete 
while openstack coe cluster list -f value -c name | grep [a-zA-Z0-9]; do sleep 5; done
#openstack coe cluster template list -f value -c name | xargs -r openstack coe cluster template delete

openstack share list -f value -c ID | xargs -r openstack share delete

openstack loadbalancer list -f value -c id | xargs -I% openstack loadbalancer delete --cascade %

openstack database instance list -f value -c ID | xargs -r openstack database instance delete
