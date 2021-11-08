#!/bin/bash

set -xe

# source venv
cd workspace
source kolla-venv/bin/activate

CONFIG_DIR=$(pwd)/etc/kolla

# source admin rc
. $CONFIG_DIR/admin-openrc.sh

# windows image (more images: https://tech-latest.com/download-latest-windows-10-iso/)
wget https://bit.ly/369BBjT -O windows10_x32.iso

openstack image create --progress --disk-format iso --container-format bare --public \
    --property os_type=windows --file windows10_x32.iso windows10_x32

rm windows10_x32.iso
