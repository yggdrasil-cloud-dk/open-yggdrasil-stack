#!/bin/bash

# Based on https://docs.openstack.org/kolla-ansible/latest/user/quickstart.html

set -xe

# source venv
cd workspace
source kolla-venv/bin/activate

# install openstack clients
pip install -U -c https://releases.openstack.org/constraints/upper/$OPENSTACK_RELEASE \
  python-openstackclient \
  python-heatclient \
  python-troveclient \
  python-magnumclient \
  python-cloudkittyclient \
  gnocchiclient \
  aodhclient \
  python-neutronclient \
  python-designateclient \
  python-muranoclient \
  python-manilaclient \
  python-solumclient \
  python-zunclient \
  python-barbicanclient
