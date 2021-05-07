#!/bin/bash

# install net-tools
apt install -y net-tools

# remove default netplan config
rm -rf /etc/netplan/01-network-manager-all.yaml

# get interface name - assuming only one interface with internet access / default route
interface=$(ip route | grep "^default" | awk '{print $5}')

# create new network config
cat > /etc/netplan/01-vlans.yaml << EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    $interface:
      dhcp4: yes

  vlans:
    # openstack management vlan
    vlan.10:
      id: 10
      link: $interface
      addresses: [10.0.10.1/24]
    # ceph public vlan
    vlan.50:
      id: 50
      link: $interface
      addresses: [10.0.50.1/24]
    # ceph cluster vlan
    vlan.60:
      id: 60
      link: $interface
      addresses: [10.0.60.1/24]
    # neutron external vlan
    # TODO: might need to change
    vlan.100:
      id: 100
      link: $interface
      addresses: [10.0.100.1/24]
EOF

# netplan apply
netplan apply

# remove network manager
systemctl stop NetworkManager.service
systemctl disable NetworkManager.service

# enable ip forwarding
sysctl -w net.ipv4.ip_forward=1
sed -i 's/.*net.ipv4.ip_forward=.*/net.ipv4.ip_forward=1/g' /etc/sysctl.conf

