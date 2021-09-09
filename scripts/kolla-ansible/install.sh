#!/bin/bash

# Based on https://docs.openstack.org/kolla-ansible/latest/user/quickstart.html

set -xe

# source venv
cd workspace
source kolla-venv/bin/activate

# install kolla-ansible
#pip install kolla-ansible==12.*
pip install kolla-ansible

# create config dir for kolla
mkdir -p etc/kolla

# copy config files to config dir
cp -r kolla-venv/share/kolla-ansible/etc_examples/kolla/* etc/kolla

# create inventory directory in workspace
mkdir -p inventory

# copy inventory files to current dir
cp kolla-venv/share/kolla-ansible/ansible/inventory/* inventory
