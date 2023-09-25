#!/bin/bash

# Based on https://docs.openstack.org/kolla-ansible/latest/user/quickstart.html

set -xe

# source venv
cd workspace
source kolla-venv/bin/activate
source etc/kolla/admin-openrc.sh

pip install git+https://opendev.org/openstack/tempest

rm -rf tempest-workspace
tempest workspace remove --name tempest-workspace || true
mkdir -p tempest-workspace
cd tempest-workspace
tempest init

#curl -s https://docs.openstack.org/tempest/latest/_static/tempest.conf.sample -o /etc/tempest/tempest.conf

function add_to_tempest_conf {
  section=$1
  config=$2
  file=./etc/tempest.conf

  grep -q "^\[$section\]$" $file || echo -e "\n[$section]" | tee -a $file
  sed -i "/\[$section\]/a $config" $file
}

add_to_tempest_conf auth "admin_username = $OS_USERNAME"
add_to_tempest_conf auth "admin_password = $OS_PASSWORD"
add_to_tempest_conf auth "admin_project_name = $OS_PROJECT_NAME"
add_to_tempest_conf auth "admin_domain_name = $OS_PROJECT_DOMAIN_NAME"

add_to_tempest_conf identity "auth_version = v$OS_IDENTITY_API_VERSION"
add_to_tempest_conf identity "uri_v3 = $OS_AUTH_URL/v3"

tempest run
