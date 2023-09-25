#!/bin/bash

# Based on https://docs.openstack.org/kolla-ansible/latest/user/quickstart.html

set -xe

# source venv
cd workspace
source kolla-venv/bin/activate
source etc/kolla/admin-openrc.sh

rm -rf tempest
git clone https://opendev.org/openstack/tempest
pip install tempest/

rm -rf tempest-workspace
tempest workspace remove --name tempest-workspace || true
mkdir -p tempest-workspace
cd tempest-workspace
tempest init

mkdir -p /etc/tempest/
cat > /etc/tempest/tempest.conf <<EOF
[auth]
admin_username = $OS_USERNAME
admin_password = $OS_PASSWORD
admin_project_name = $OS_PROJECT_NAME
admin_domain_name = $OS_PROJECT_DOMAIN_NAME

[identity]
auth_version = $OS_IDENTITY_API_VERSION
uri_v3 = $OS_AUTH_URL
EOF

tempest run
