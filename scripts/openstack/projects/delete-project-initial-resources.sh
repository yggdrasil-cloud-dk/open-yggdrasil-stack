#!/bin/bash

PROJECT=$1

echo "====== PROJECT: $PROJECT ======="

set -x

# servers
openstack server list -f value --all-projects | grep $PROJECT | awk '{print $1}' | xargs -I % -P 5 openstack server delete %
# volumes
openstack volume list -f value --all-projects | grep $PROJECT | awk '{print $1}' | xargs -I % -P 5 openstack volume delete %  # volumes
# routers
for router in $(openstack router list -f value | grep $PROJECT | awk '{print $1}'); do
        openstack port list -f value --router $router | awk '{print $1}' | xargs -I % -P 5 openstack router remove port $router %
        openstack router delete $router
done
# networks
for network in $(openstack network list -f value -c Name | grep $PROJECT); do
        openstack port list -f value --network $network | awk '{print $1}' | xargs -I % -P 5 openstack port delete %
        # subnets
        for subnet in $(openstack subnet list -f value -c Name --network $network); do
                openstack subnet delete $subnet
        done
        openstack network delete $network
done
# security groups
openstack security group list -f value | grep $PROJECT | awk '{print $1}' | xargs -I % -P 5 openstack security group delete %

openstack project delete $PROJECT

