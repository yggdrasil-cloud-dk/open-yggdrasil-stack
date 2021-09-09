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
set_global_config neutron_external_interface neutron_ext
#set_global_config neutron_external_interface $(ip route | grep "^default" | awk '{print $5}')
set_global_config kolla_internal_vip_address 10.0.10.100

set_global_config glance_backend_ceph yes
set_global_config glance_backend_file no
set_global_config ceph_glance_keyring ceph.client.admin.keyring
set_global_config ceph_glance_user admin

set_global_config nova_backend_ceph yes
set_global_config ceph_nova_keyring ceph.client.admin.keyring
set_global_config ceph_nova_user admin

set_global_config enable_cinder yes
set_global_config cinder_backend_ceph yes
set_global_config ceph_cinder_keyring ceph.client.admin.keyring
set_global_config ceph_cinder_user admin

set_global_config enable_cinder_backup no

for service in glance nova cinder/cinder-volume; do
	mkdir -p /etc/kolla/config/$service/
	cp /etc/ceph/ceph.client.admin.keyring /etc/kolla/config/$service/
	cat /etc/ceph/ceph.conf | sed 's/^\t//g' > /etc/kolla/config/$service/ceph.conf
done
