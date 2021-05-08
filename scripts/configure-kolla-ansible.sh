#!/bin/bash

# Based on https://docs.openstack.org/kolla-ansible/latest/user/quickstart.html

CONFIG_DIR=etc/kolla

# just sets `<key>: <value>` in globals.yml
function set_global_config () {
	config_key=$1
	config_value=$2
	# handles when comments only in beginning of line
	sed -i "s/#\?\( *$config_key:\).*/\1 $config_value/g" $CONFIG_DIR/globals.yml
}

set -xe

# source venv
cd workspace
source kolla-venv/bin/activate

# generate passwords
kolla-genpwd -p $CONFIG_DIR/passwords.yml

# set global configs
set_global_config kolla_base_distro ubuntu
set_global_config kolla_install_type source
set_global_config network_interface openstack_mgmt
set_global_config neutron_external_interface neutron_external
set_global_config kolla_internal_vip_address 10.0.10.100

# get python path in venv
PYTHON_PATH=$(realpath -s kolla-venv/bin/python)

# configure ansible
cat > ansible.cfg << EOF
[defaults]
host_key_checking=False
pipelining=True
forks=10
inventory = inventory/$INVENTORY
force_valid_group_names = ignore
interpreter_python = $PYTHON_PATH
EOF
