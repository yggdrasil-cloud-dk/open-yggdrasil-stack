#!/bin/bash

set -xe

# source venv
cd workspace
source kolla-venv/bin/activate

CONFIG_DIR=$(pwd)/etc/kolla

# source admin rc
. $CONFIG_DIR/admin-openrc.sh

# upload ubuntu image
image_urls=(
	https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
	https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/35.20220116.3.0/x86_64/fedora-coreos-35.20220116.3.0-openstack.x86_64.qcow2.xz
	https://tarballs.opendev.org/openstack/trove/images/trove-zed-guest-ubuntu-focal.qcow2
)

for image_url in ${image_urls[@]}; do
	pipe_cmd=cat
	# remove file extension
	image_name=$(echo $(basename $image_url) | grep -o ".*\." | head -c -2)
	if [[ "$image_url" == *".xz" ]]; then
		echo Image detected to be xz compressed. Will decompress.
		# removing file extension again - (probably .qcow2 or .img)
		image_name=$(echo $image_name | grep -o ".*\." | head -c -2)
		pipe_cmd="xz -d -"

	fi
	image_type=qcow2
	openstack image show $image_name || curl $image_url --output - | $pipe_cmd | openstack image create $image_name --disk-format qcow2
done
