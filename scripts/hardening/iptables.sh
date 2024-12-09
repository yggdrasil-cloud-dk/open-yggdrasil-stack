#!/bin/bash

rules=(
  "\-A INPUT -i lo -j ACCEPT"
  "\-A INPUT -p icmp -j ACCEPT"
  "\-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT"
  "\-A INPUT -s $NETWORK_PROVIDER_NET -p tcp -m tcp --dport 22 -j DROP"
  "\-A INPUT -p tcp -m tcp --dport 22 -j ACCEPT"
  "\-A INPUT -s $OPENSTACK_MGMT_NET -j ACCEPT"
  "\-A INPUT -s $CEPH_PUBLIC_NET -j ACCEPT"
  "\-A INPUT -s $CEPH_CLUSTER_NET -j ACCEPT"
  "\-A INPUT -s $NETWORK_PROVIDER_NET -j ACCEPT"
  "\-A INPUT -s $NODE_MGMT_NET -j ACCEPT"
)

set -x

iptables --policy INPUT ACCEPT

for rule in "${rules[@]}"; do
  (iptables-save | grep -q "$rule") || (echo "Adding rule \"$rule\"" && eval "iptables $rule")
done

iptables --policy INPUT DROP
