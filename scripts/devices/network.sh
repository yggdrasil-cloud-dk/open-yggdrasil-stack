#!/bin/bash

set -xe

# install net-tools
apt install -y net-tools

# remove default netplan config
rm -rf /etc/netplan/01-network-manager-all.yaml

# get interface name - assuming only one interface with internet access / default route
interface=$(ip route | grep "^default" | grep -o 'dev .\+' | cut -d ' ' -f 2)

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
    openstack_mgmt:
      id: 10
      link: $interface
      addresses: [10.0.10.1/24]
    # ceph public vlan
    ceph_public:
      id: 50
      link: $interface
      addresses: [10.0.50.1/24]
    # ceph cluster vlan
    ceph_cluster:
      id: 60
      link: $interface
      addresses: [10.0.60.1/24]
EOF

# netplan apply
netplan apply

# remove network manager
systemctl stop NetworkManager.service
systemctl disable NetworkManager.service

# enable ip forwarding
sysctl -w net.ipv4.ip_forward=1
sed -i 's/.*net.ipv4.ip_forward=.*/net.ipv4.ip_forward=1/g' /etc/sysctl.conf

# TODO: find a better way to do this!!

# wait for internet connectivity
while (! ping -c 3 8.8.8.8); do sleep 5; done

ip=$(ip -o -f inet addr | grep $interface | awk '{print $4}')
test -e /opt/check_internet_access.sh || cat > /opt/check_internet_access.sh << EOF
#!/bin/bash

while true; do
  if (ip a | grep -q br-ex); then
    if (! ping -c 3 8.8.8.8 > /dev/null 2>&1); then 
      ip addr flush dev $interface
      ip addr add $ip dev br-ex
      ip link set br-ex up
    fi
  fi
  sleep 5
done
EOF

test -e /etc/systemd/system/internet-access-bridge.service || cat > /etc/systemd/system/internet-access-bridge.service << EOF
[Unit]
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=-/bin/bash /opt/check_internet_access.sh

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable internet-access-bridge
systemctl start internet-access-bridge


