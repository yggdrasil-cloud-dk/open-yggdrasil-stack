#!/bin/bash

# Based on https://docs.openstack.org/kolla-ansible/latest/user/quickstart.html

set -xe

# source venv
cd workspace
source kolla-venv/bin/activate

CONFIG_DIR=$(pwd)/etc/kolla

# source admin rc
. $CONFIG_DIR/admin-openrc.sh


DEFAULT_IF=$(ip route | grep "^default" | grep -o 'dev .\+' | cut -d ' ' -f 2 | head -n 1)
DEFAULT_NETMASK=$(ifconfig $DEFAULT_IF | grep -o "netmask .\+" | cut -d ' ' -f 2)

#if [[ $DEFAULT_NETMASK != "255.255.255.0" ]]; then
#	echo "Script can't handle this netmask"
#	exit 1
#fi


export EXT_NET_CIDR=10.38.3.0/24
export EXT_NET_RANGE="start=10.38.3.101,end=10.38.3.200"
export EXT_NET_GATEWAY=10.38.3.1

export KOLLA_CONFIG_PATH=$CONFIG_DIR
export ENABLE_EXT_NET=0

#openstack network create --external --provider-physical-network physnet1 --provider-network-type vlan public1 --provider-segment 600
openstack network show public1  || \
	(openstack network create --external --provider-physical-network physnet1 --provider-network-type flat public1 && \
	openstack subnet create --no-dhcp --allocation-pool ${EXT_NET_RANGE} --network public1 --subnet-range ${EXT_NET_CIDR} --gateway ${EXT_NET_GATEWAY} public1-subnet )

./kolla-ansible/tools/init-runonce
