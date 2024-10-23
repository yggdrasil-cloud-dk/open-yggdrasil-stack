
set -xe

# Networks & Subnets

create_network_and_subnet () {
	openstack network show $network_name || openstack network create $network_name
	openstack subnet show $subnet_name || openstack subnet create $subnet_name --dns-nameserver 8.8.8.8  --allocation-pool ${subnet_range} --network $network_name --subnet-range ${subnet_cidr}
}

network_name=image-builder_net
subnet_name=image-builder_subnet
subnet_cidr=172.16.1.0/24
subnet_range="start=172.16.1.101,end=172.16.1.254"
create_network_and_subnet

# Router

router=image-builder_router
openstack router show $router || openstack router create $router
openstack router set --external-gateway public1 $router
attached_subnet_ids=$(openstack router show $router -f value -c interfaces_info | sed "s/'/\"/g" | jq -r .[].subnet_id)
echo $attached_subnet_ids | grep -q $(openstack subnet show $subnet_name -f value -c id) || openstack router add subnet $router $subnet_name


# Security Groups

nsg=image-builder_nsg
openstack security group show $nsg || openstack security group create $nsg
openstack security group rule create $nsg --protocol tcp --dst-port 22 || true
openstack security group rule create $nsg --protocol icmp || true  # TODO: remove
openstack security group rule create $nsg --protocol tcp || true  # TODO: remove
openstack security group rule create $nsg --protocol udp || true  # TODO: remove


# Volume
volume_name=image-builder_vol
openstack volume show $volume_name || openstack volume create $volume_name --size 100 

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

# virt-manager install
apt update
apt install -y virt-manager

# packer install
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository --yes "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt update && apt install packer

mkdir -p /var/lib/libvirt/packer
cd /var/lib/libvirt/packer

# create patch file
echo 'diff --git a/win2022-gui.json b/win2022-gui.json
index 5041d00..1a70399 100644
--- a/win2022-gui.json
+++ b/win2022-gui.json
@@ -86,2 +86,3 @@
             "winrm_timeout": "4h",
+            "vnc_bind_address": "0.0.0.0",
             "qemuargs": [ [ "-cdrom", "{{user `virtio_iso_path`}}" ] ],' > /tmp/packer.diff

# taken from https://github.com/eaksel/packer-Win2022
git clone https://github.com/eaksel/packer-Win2022.git
cd packer-Win2022

# apply patch
git apply /tmp/packer.diff

# download virtio iso
wget https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.229-1/virtio-win-0.1.229.iso

# plugin config
cat > template.pkr.hcl <<EOT
packer {
  required_plugins {
    qemu = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}
EOT

packer init .

PACKER_LOG=1 packer build -only=qemu win2022-gui.json #Windows Server 2022 w/ GUI

EOF

# VM and Floating IP

vm_name=image-builder
openstack server show $vm_name || openstack server create \
    --image jammy-server-cloudimg-amd64 \
    --flavor m1.large \
    --network $network_name \
    --security-group $nsg \
    --user-data /tmp/user_data.sh \
    $vm_name


if [[ -z $(openstack floating ip list | grep $(openstack port list --server $vm_name -f value -c id) ) ]]; then
  fip=$(openstack floating ip list -f value | grep "None None" | head -n 1 | awk '{print $2}')
  if [[ -z $fip ]]; then
    fip=$(openstack floating ip create public1 -f value -c floating_ip_address)
  fi
  openstack server add floating ip $vm_name $fip
fi

while ! [[ $(openstack server show $vm_name -f value -c status) == ACTIVE ]]; do sleep 5; done

openstack volume show $volume_name -f value -c status | grep -q available && \
openstack server add volume $vm_name $volume_name

