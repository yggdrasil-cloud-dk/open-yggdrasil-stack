#!/bin/bash

# Based on https://docs.openstack.org/kolla-ansible/latest/user/quickstart.html

set -xe

# source venv
cd workspace
source kolla-venv/bin/activate

# install kolla-ansible
rm -rf kolla-ansible
git clone --branch stable/2023.1 https://github.com/openstack/kolla-ansible.git

# apply patch and setup
cd kolla-ansible
git apply ../../kolla-ansible.patch
python3 setup.py develop
cd ..

# install ansible galaxy deps
kolla-ansible install-deps

# create config dir for kolla
mkdir -p etc/kolla

# copy config files to config dir
cp -r kolla-ansible/etc/kolla/globals.yml etc/kolla/globals.yml

# add section for additional configs
cat >> etc/kolla/globals.yml <<-EOF
	
	######################
	# Additional Configs #
	######################
	EOF

# copy password file if it doesn't exist
test -f etc/kolla/passwords.yml || cp kolla-ansible/etc/kolla/passwords.yml etc/kolla/passwords.yml

# create inventory directory in workspace
mkdir -p inventory

cat kolla-ansible/ansible/inventory/all-in-one | sed -n '/common/,$p' > inventory/99-openstack_groups
