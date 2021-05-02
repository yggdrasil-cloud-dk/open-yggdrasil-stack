#!/bin/bash

# Based on https://docs.openstack.org/kolla-ansible/latest/user/quickstart.html

INVENTORY="${INVENTORY:=all-in-one}"

set -x

# source venv
cd workspace
source kolla-venv/bin/activate

# install kolla-ansible
pip install kolla-ansible

# create config dir for kolla
mkdir -p etc/kolla

# copy config files to config dir
cp -r kolla-venv/share/kolla-ansible/etc_examples/kolla/* etc/kolla

# create inventory directory in workspace
mkdir -p inventories

# copy inventory files to current dir
cp kolla-venv/share/kolla-ansible/ansible/inventory/* inventories

# configure ansible
cat > ansible.cfg << EOF
[defaults]
host_key_checking=False
pipelining=True
forks=10
inventory = inventories/$INVENTORY
force_valid_group_names = ignore
EOF
