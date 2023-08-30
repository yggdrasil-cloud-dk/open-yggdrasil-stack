#!/bin/bash

# Based on https://docs.openstack.org/kolla-ansible/latest/user/quickstart.html

set -xe

# source venv
cd workspace
source kolla-venv/bin/activate

CONFIG_DIR=$(pwd)/etc/kolla

# source admin rc
. $CONFIG_DIR/admin-openrc.sh


DEFAULT_IF=$(ip route | grep "^default" | grep -o 'dev .\+' | cut -d ' ' -f 2)
DEFAULT_NETMASK=$(ifconfig $DEFAULT_IF | grep -o "netmask .\+" | cut -d ' ' -f 2)

if [[ $DEFAULT_NETMASK != "255.255.255.0" ]]; then
	echo "Script can't handle this netmask"
	exit 1
fi

DEFAULT_GW_ROUTE=$(ip route | grep "^default")
DEFAULT_GW_IP=$(echo $DEFAULT_GW_ROUTE | grep -o 'via .\+' | cut -d ' ' -f 2)
DEFAULT_GW_FIRST_THREE_OCTETS=$(echo $DEFAULT_GW_ROUTE | grep -o 'via [0-9]\+\.[0-9]\+\.[0-9]\+' | cut -d ' ' -f 2)

export EXT_NET_CIDR="$DEFAULT_GW_FIRST_THREE_OCTETS.0/24"
export EXT_NET_RANGE="start=$DEFAULT_GW_FIRST_THREE_OCTETS.150,end=$DEFAULT_GW_FIRST_THREE_OCTETS.199"
export EXT_NET_GATEWAY=$DEFAULT_GW_IP

export KOLLA_CONFIG_PATH=$CONFIG_DIR

./kolla-ansible/tools/init-runonce
