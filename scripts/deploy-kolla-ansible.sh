#!/bin/bash

# Based on https://docs.openstack.org/kolla-ansible/latest/user/quickstart.html

CONFIGDIR="${CONFIGDIR:=etc/kolla/}"

set -xe

# source venv
cd workspace
source kolla-venv/bin/activate

# bootstrap server
kolla-ansible --configdir $CONFIGDIR bootstrap-servers

# pre-deployment checks
kolla-ansible --configdir $CONFIGDIR prechecks

# deploy
kolla-ansible --configdir $CONFIGDIR deploy
