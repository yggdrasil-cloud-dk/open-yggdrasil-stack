#!/bin/bash

# Based on https://docs.openstack.org/kolla-ansible/latest/user/quickstart.html

CONFIG_DIR=etc/kolla

# just sets `<key>: <value>` in globals.yml
function set_global_config () {
	config_key=$1
	config_value=$2
	# handles when comments only in beginning of line
	if grep -q $config_key $CONFIG_DIR/globals.yml; then
		sed -i "s/#\?\( *$config_key:\).*/\1 $config_value/g" $CONFIG_DIR/globals.yml
	else
		sed -i "$ a $config_key: $config_value" $CONFIG_DIR/globals.yml
	fi
}

set -xe

# source venv
cd workspace
source kolla-venv/bin/activate

# generate passwords
PW_FILE=$CONFIG_DIR/passwords.yml
if [ ! -f "$PW_FILE" ]; then
	echo "$PW_FILE not found"
fi

if grep ^[a-z_]*: $PW_FILE | sed 's/.*://g' | xargs | grep -q '[[:alnum:]]'; then
	echo "password file exists and has passwords"
else
	echo "generating passwords.."
        kolla-genpwd -p $CONFIG_DIR/passwords.yml
fi

# set global configs
set_global_config kolla_base_distro ubuntu
set_global_config kolla_install_type source

set_global_config network_interface openstack_mgmt
set_global_config neutron_external_interface veth1
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

set_global_config enable_cinder_backup yes
set_global_config ceph_cinder_backup_keyring ceph.client.admin.keyring
set_global_config ceph_cinder_backup_user admin

set_global_config enable_ceph_rgw yes

set_global_config neutron_plugin_agent ovn

set_global_config enable_aodh yes
set_global_config enable_barbican yes
set_global_config enable_ceilometer yes
set_global_config enable_central_logging yes
set_global_config enable_cloudkitty yes
set_global_config enable_designate yes
set_global_config enable_freezer yes
set_global_config enable_gnocchi yes
set_global_config enable_grafana yes
set_global_config enable_kuryr yes
set_global_config enable_magnum yes
set_global_config enable_manila yes
set_global_config enable_manila_backend_generic yes
set_global_config enable_murano yes
set_global_config enable_octavia yes
set_global_config enable_prometheus yes
set_global_config enable_sahara yes
set_global_config enable_senlin yes
set_global_config enable_skyline yes
set_global_config enable_solum yes
set_global_config enable_trove yes
set_global_config enable_venus yes
#set_global_config enable_vitrage yes
set_global_config enable_watcher yes
set_global_config enable_zun yes

set_global_config octavia_provider_drivers '"amphora:Amphora provider, ovn:OVN provider"'

set_global_config ceph_rgw_hosts "[ { 'host': '$(hostname)', 'ip': '$(ip --json address show ceph_public | jq -r .[0].addr_info[0].local)', 'port': 6780 } ]"

for service in glance nova cinder/cinder-volume cinder/cinder-backup; do
	mkdir -p etc/kolla/config/$service/
	cp /etc/ceph/ceph.client.admin.keyring etc/kolla/config/$service/
	cat /etc/ceph/ceph.conf | sed 's/^\t//g' > etc/kolla/config/$service/ceph.conf
done
