#!/bin/bash

# Based on https://docs.openstack.org/kolla-ansible/latest/user/quickstart.html

set -x

# source venv
cd workspace
source kolla-venv/bin/activate
source etc/kolla/admin-openrc.sh

# delete various resources
openstack server list -f value | awk '{print $1}' | xargs -I % openstack server delete %
openstack volume list -f value | awk '{print $1}' | xargs -I % openstack volume delete %
openstack keypair list -f value | awk '{print $1}' | xargs -I % openstack keypair delete %
openstack security group list -f value | awk '{print $1}' | xargs -I % openstack security group delete %
for router in $(openstack router list -f value | awk '{print $1}'); do
	for router_port in $(openstack port list --router $router -f value | awk '{print $1}'); do
		openstack router remove port $router $router_port
	done
	openstack router delete $router
done
openstack subnet list -f value | awk '{print $1}' | xargs -I % openstack subnet delete %
openstack network list -f value | awk '{print $1}' | xargs -I % openstack network delete %
openstack image list -f value | awk '{print $1}' | xargs -I % openstack image delete %
