#!/bin/bash

set -xe

# source venv
cd workspace
source kolla-venv/bin/activate

CONFIG_DIR=$(pwd)/etc/kolla

# source admin rc
. $CONFIG_DIR/admin-openrc.sh

# upload ubuntu image
$image_urls=(
	https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
)

for image_url in $image_urls; do
	image_name=basename $(image_url)
	openstack image show $image_name || curl $image_url --output - | openstack image create $image_name
done
