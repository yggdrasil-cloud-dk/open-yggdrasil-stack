#!/bin/bash

# Based on https://docs.openstack.org/kolla-ansible/latest/user/quickstart.html

CONFIG_DIR=etc/kolla

set -xe

# source venv
cd workspace
source kolla-venv/bin/activate

# bootstrap server
kolla-ansible --configdir $CONFIG_DIR bootstrap-servers

# pre-deployment checks
kolla-ansible --configdir $CONFIG_DIR prechecks

# deploy
kolla-ansible --configdir $CONFIG_DIR deploy
