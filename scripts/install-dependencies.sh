#!/bin/bash

# Based on documentation from https://docs.openstack.org/kolla-ansible/latest/user/quickstart.html

set -xe

mkdir -p workspace
cd workspace

# update repos
apt update

# install python and deps
apt install python3-dev libffi-dev gcc libssl-dev

# install venv
apt install python3-venv

# create venv
python3 -m venv kolla-venv

# source path
source kolla-venv/bin/activate

# upgrade pip
pip install -U pip

# install ansible
pip install 'ansible<3.0'
