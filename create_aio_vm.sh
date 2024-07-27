
set -xe

# Networks & Subnets

create_network_and_subnet () {
	network=$1
	subnet_cidr=$2
	subnet_range=$3
	openstack network show $network || openstack network create $network
  # create subnet with the same name as network
	openstack subnet show $network || openstack subnet create $network --dns-nameserver 10.38.1.130  --allocation-pool ${subnet_range} --network $network --subnet-range ${subnet_cidr}
}

network=aio_net
subnet_cidr=192.168.100.0/24
subnet_range="start=192.168.100.101,end=192.168.100.254"
create_network_and_subnet $network $subnet_cidr $subnet_range

# Router

router=aio_router
openstack router show $router || openstack router create $router
openstack router set --external-gateway public1 $router
attached_subnet_ids=$(openstack router show $router -f value -c interfaces_info | sed "s/'/\"/g" | jq -r .[].subnet_id)

subnet_name=$network
echo $attached_subnet_ids | grep -q $(openstack subnet show $subnet_name -f value -c id) || openstack router add subnet $router $subnet_name


# Security Groups

nsg=aio_nsg
openstack security group show $nsg || openstack security group create $nsg
openstack security group rule create $nsg --protocol tcp --dst-port 22 || true
openstack security group rule create $nsg --protocol icmp || true  # TODO: remove
openstack security group rule create $nsg --protocol tcp || true  # TODO: remove
openstack security group rule create $nsg --protocol udp || true  # TODO: remove

# Flavor

openstack flavor show aio || openstack flavor create aio --private --ram 65536 --disk 300 --vcpus 16 

# Volume

openstack volume show aio-ceph || openstack volume create aio-ceph --size 300 

# User-data

cat > /tmp/user_data.sh <<EOF
#!/bin/bash

set -x

# enable password ssh
sed 's/.*PasswordAuthentication no/PasswordAuthentication yes/' -i /etc/ssh/sshd_config
rm -rf /etc/ssh/sshd_config.d/*
systemctl restart sshd

# change password
echo "ubuntu:ubuntu" | chpasswd

EOF

# VM and Floating IP

vm_name=aio
openstack server show $vm_name || \
openstack server create \
    --image jammy-server-cloudimg-amd64 \
    --flavor aio \
    --network $network \
    --user-data /tmp/user_data.sh \
    $vm_name -f value -c id && \
fip=$(openstack floating ip create public1 -f value -c floating_ip_address) && \
openstack server add floating ip $vm_name $fip && \
openstack server add volume $vm_name aio-ceph


