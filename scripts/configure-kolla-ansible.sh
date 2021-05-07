#!/bin/bash

# Based on https://docs.openstack.org/kolla-ansible/latest/user/quickstart.html

CONFIG_DIR=etc/kolla

function set_global_config () {
	config_key=$1
	config_value=$2
	# handles when comments only in beginning of line
	sed -i "s/#\?\( *$config_key:\).*/\1 $config_value/g" $CONFIG_DIR/globals.yml
}

set -x

# source venv
cd workspace
source kolla-venv/bin/activate

# generate passwords
kolla-genpwd -p $CONFIG_DIR/passwords.yml

# set global configs
set_global_config kolla_base_distro ubuntu
set_global_config kolla_install_type source
#TODO: fix these
set_global_config network_interface eth1
set_global_config neutron_external_interface eth2
set_global_config kolla_internal_vip_address 10.3.5.10
