#!/bin/bash

set -xe

# source venv
cd workspace
source kolla-venv/bin/activate

CONFIG_DIR=$(pwd)/etc/kolla

# source admin rc
. $CONFIG_DIR/admin-openrc.sh


openstack flavor show c1 || openstack flavor create --id c1 --ram 256 --disk 1 --vcpus 1 --property hw_rng:allowed=True cirros256
openstack flavor show d1 ||openstack flavor create --id d1 --ram 512 --disk 5 --vcpus 1 --property hw_rng:allowed=True ds512M
openstack flavor show d2 ||openstack flavor create --id d2 --ram 1024 --disk 10 --vcpus 1 --property hw_rng:allowed=True ds1G
openstack flavor show d3 ||openstack flavor create --id d3 --ram 2048 --disk 10 --vcpus 2 --property hw_rng:allowed=True ds2G
openstack flavor show d4 ||openstack flavor create --id d4 --ram 4096 --disk 20 --vcpus 4 --property hw_rng:allowed=True ds4G

fedora_image="$(openstack image list -f value -c Name | grep fedora-coreos)"

# should fail if this isn't true
test $(echo "$fedora_image" | wc -l) -eq 1

openstack image set --property os_distro=fedora-coreos $fedora_image

ls ~/.ssh/id_rsa || ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""

openstack keypair show testkey || openstack keypair create --public-key ~/.ssh/id_rsa.pub testkey

openstack network show public || (openstack network show public1 && openstack network set --name public public1)

sleep 3

openstack coe cluster template show k8s-cluster-template || openstack coe cluster template create k8s-cluster-template \
    --image $fedora_image \
    --keypair testkey \
    --external-network public \
    --dns-nameserver 8.8.8.8 \
    --flavor ds1G \
    --master-flavor ds2G \
    --docker-volume-size 5 \
    --volume-driver cinder \
    --network-driver flannel \
    --docker-storage-driver overlay2 \
    --coe kubernetes \
    --labels container_runtime=containerd,kube_tag=v1.25.9-rancher2,cloud_provider_enabled=true

openstack coe cluster create k8s-cluster \
    --cluster-template k8s-cluster-template \
     --node-count 1
