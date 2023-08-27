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

# ensure pyopenssl installed and updated
pip install -U pyopenssl

# create venv
# NOTE: adding `--system-site-packages` because it needs python-apt module`
python3 -m venv --system-site-packages kolla-venv

# source path
source kolla-venv/bin/activate

# upgrade pip
pip install -U pip

# install ansible
ANSIBLE_SKIP_CONFLICT_CHECK=1 pip install -U --ignore-installed 'ansible>=6,<8'

# get python path in venv
#PYTHON_PATH=$(realpath -s kolla-venv/bin/python)

# configure ansible
cp /etc/ansible/ansible.cfg ansible.cfg
