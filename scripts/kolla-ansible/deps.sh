#!/bin/bash

# Based on documentation from https://docs.openstack.org/kolla-ansible/latest/user/quickstart.html

set -xe

mkdir -p workspace
cd workspace

# update repos
apt update

# install python and deps
apt install -y python3-dev libffi-dev gcc libssl-dev

# install venv
apt install -y python3-venv

# create venv
# NOTE: adding `--system-site-packages` because it needs python-apt module`
python3 -m venv --system-site-packages kolla-venv

# source path
source kolla-venv/bin/activate

# upgrade pip
pip install -U pip

# install ansible
pip install -U 'ansible==2.9.*'

# get python path in venv
PYTHON_PATH=$(realpath -s kolla-venv/bin/python)
INVENTORY="${INVENTORY:=all-in-one}"

# configure ansible
cat > ansible.cfg << EOF
[defaults]
host_key_checking=False
pipelining=True
forks=10
inventory = inventory/$INVENTORY
force_valid_group_names = ignore
interpreter_python = $PYTHON_PATH
EOF