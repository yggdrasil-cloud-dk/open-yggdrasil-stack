#!/bin/bash

# Based on https://docs.openstack.org/kolla-ansible/latest/user/quickstart.html

set -xe

# source venv
cd workspace
source kolla-venv/bin/activate

# install openstack client
pip install -U python-openstackclient -c https://releases.openstack.org/constraints/upper/2023.1
pip install -U python-heatclient -c https://releases.openstack.org/constraints/upper/2023.1
pip install -U python-troveclient -c https://releases.openstack.org/constraints/upper/2023.1
pip install -U python-magnumclient -c https://releases.openstack.org/constraints/upper/2023.1
pip install -U python-cloudkittyclient -c https://releases.openstack.org/constraints/upper/2023.1

