
set -xe

# Networks & Subnets

create_network_and_subnet () {
	network=$1
	subnet_cidr=$2
	subnet_range=$3
	openstack network show $network || openstack network create $network
	openstack subnet show $network || openstack subnet create $network --dns-nameserver 10.38.1.130  --allocation-pool ${subnet_range} --network $network --subnet-range ${subnet_cidr}
}


# app 
network=aio_net
subnet_cidr=192.168.100.0/24
subnet_range="start=192.168.100.101,end=192.168.100.254"
create_network_and_subnet $network $subnet_cidr $subnet_range

# Router

router=aio_router
openstack router show $router || openstack router create $router --project $PROJECT
openstack router set --external-gateway public $router
attached_subnet_ids=$(openstack router show $router -f value -c interfaces_info | sed "s/'/\"/g" | jq -r .[].subnet_id)

for subnet_name in $network; do
	echo $attached_subnet_ids | grep -q $(openstack subnet show $subnet_name -f value -c id) || openstack router add subnet $router $subnet_name
done


# Security Groups

nsg=aio_nsg
openstack security group show $nsg || openstack security group create $nsg
openstack security group rule create $nsg --protocol tcp --dst-port 22 || true
openstack security group rule create $nsg --protocol icmp || true  # TODO: remove
openstack security group rule create $nsg --protocol tcp || true  # TODO: remove
openstack security group rule create $nsg --protocol udp || true  # TODO: remove


# aio

cat > /tmp/user_data.sh <<EOF
#!/bin/bash

set -x

sed 's/.*PasswordAuthentication no/PasswordAuthentication yes/' -i /etc/ssh/sshd_config
rm -rf /etc/ssh/sshd_config.d/*

systemctl restart sshd

echo "ubuntu:ubuntu" | chpasswd
EOF

vm_name=$PROJECT.jump
openstack server list --project $PROJECT | grep -q $vm_name || (
  user=${PROJECT}.bot && \
  password=$(echo $RANDOM | sha1sum | head -c 16) && \
  openstack user create --password $password $user && \
  openstack role add --user $user --project $PROJECT member && \
  (openstack --os-username $user --os-password $password --os-project-name $PROJECT security group rule create default \
  --protocol tcp || true) && \
  (openstack --os-username $user --os-password $password --os-project-name $PROJECT security group rule create default \
  --protocol udp || true) && \
  vm_id=$(openstack --os-username $user --os-password $password --os-project-name $PROJECT server create \
    --image jammy-server-cloudimg-amd64 \
    --flavor m1.small \
    --network $PROJECT.mgmt \
    $vm_name -f value -c id --user-data /tmp/user_data.sh) && \
  openstack user delete $user && \
  fip=$(openstack floating ip create public --project $PROJECT -f value -c floating_ip_address) && \
  openstack server add floating ip $vm_id $fip
)



