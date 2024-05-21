#!/bin/bash

set -xe

# source venv
cd workspace
source kolla-venv/bin/activate

CONFIG_DIR=$(pwd)/etc/kolla

# source admin rc
. $CONFIG_DIR/admin-openrc.sh

manila type-show default_share_type || manila type-create default_share_type True

openstack image show manila-service-image || (
  wget http://tarballs.openstack.org/manila-image-elements/images/manila-service-image-master.qcow2 && \
  glance image-create --name "manila-service-image" \
    --file manila-service-image-master.qcow2 \
    --disk-format qcow2 --container-format bare \
    --visibility public --progress && \
  rm manila-service-image-master.qcow2
)

manila share-network-show demo-share-network1 || (
  manila share-network-create --name demo-share-network1 \
	  --neutron-net-id $(openstack network show demo-net -f value -c id) \
	  --neutron-subnet-id $(openstack subnet show demo-subnet -f value -c id)
)

nova flavor-show  manila-service-flavor || nova flavor-create manila-service-flavor 100 2048 30 2


manila show demo-share1 || manila create CIFS 1 --name demo-share1 --share-network demo-share-network1 --share-type default_share_type
