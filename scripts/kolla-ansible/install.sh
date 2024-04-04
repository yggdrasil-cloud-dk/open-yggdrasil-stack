#!/bin/bash

# Based on https://docs.openstack.org/kolla-ansible/latest/user/quickstart.html

set -xe

# source venv
cd workspace
source kolla-venv/bin/activate

# install kolla-ansible
rm -rf kolla-ansible
git clone --branch stable/$OPENSTACK_RELEASE https://github.com/openstack/kolla-ansible.git

# apply patch and setup
cd kolla-ansible
git apply --reject --whitespace=fix ../../kolla-ansible.patch
python3 setup.py develop
cd ..

# install ansible galaxy deps
kolla-ansible install-deps

# create config dir for kolla
mkdir -p etc/kolla
mkdir -p etc/kolla/config/prometheus/prometheus.yml.d
mkdir -p /etc/kolla/haproxy/services.d

# copy config files to config dir
cp -r kolla-ansible/etc/kolla/globals.yml etc/kolla/globals.yml

# add section for additional configs
cat >> etc/kolla/globals.yml <<-EOF
	
	######################
	# Additional Configs #
	######################
	EOF

date_suffix=$(date +"%Y%m%dT%H%M")

# add entries to passwords file
touch etc/kolla/passwords.yml
cp etc/kolla/passwords.yml etc/kolla/passwords.yml.bk_$date_suffix
cat kolla-ansible/etc/kolla/passwords.yml | grep -v "^#\|^---" | xargs -I% bash -c "grep -q % etc/kolla/passwords.yml || (echo % | tee -a etc/kolla/passwords.yml)"

if [[ -z $(diff etc/kolla/passwords.yml etc/kolla/passwords.yml.bk_$date_suffix) ]]; then rm etc/kolla/passwords.yml.bk_$date_suffix; fi

# create inventory directory in workspace
mkdir -p inventory

cat kolla-ansible/ansible/inventory/all-in-one | sed -n '/common/,$p' > inventory/99-openstack_groups
