#!/bin/bash

# Based on https://docs.openstack.org/kolla-ansible/latest/user/quickstart.html

set -xe

# source venv
cd workspace
source kolla-venv/bin/activate

# install openstack client
pip install -U python-openstackclient

# install cryptography version because of annoying warning
pip install -U cryptography==3.3
