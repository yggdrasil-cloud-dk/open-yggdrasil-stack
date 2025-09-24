#!/bin/bash

if [[ -z $NETWORK_PROVIDER_NET ]] || [[ -z $OPENSTACK_MGMT_NET ]] || [[ -z $CEPH_PUBLIC_NET ]] || [[ -z $CEPH_CLUSTER_NET ]] || [[ -z $NETWORK_PROVIDER_NET ]] || [[ -z $NODE_MGMT_NET ]]; then
  echo Empty Env Var. Exitting..
  exit 1
fi

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
  "\-A INPUT -p tcp --dport 443 -m state --state NEW --syn -m hashlimit --hashlimit 15/s --hashlimit-burst 30 --hashlimit-mode srcip --hashlimit-srcmask 32 --hashlimit-name synattack -j ACCEPT"
  "\-A INPUT -p tcp --dport 8443 -j ACCEPT"
)

set -x

iptables --policy INPUT ACCEPT

iptables --flush INPUT


for rule in "${rules[@]}"; do
  (iptables-save | grep -q "$rule") || (echo "Adding rule \"$rule\"" && eval "iptables $rule")
done

iptables --policy INPUT DROP
