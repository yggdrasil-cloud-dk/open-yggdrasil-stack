#!/bin/bash


rules=(
  "\-A INPUT -i lo -j ACCEPT"
  "\-A INPUT -p icmp -j ACCEPT"
  "\-A INPUT -p tcp -m tcp --dport 22 -j ACCEPT"
  "\-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT"
  "\-A INPUT -s 192.168.1.0/24 -j ACCEPT"
)

set -x

iptables --policy INPUT ACCEPT

for rule in "${rules[@]}"; do
  (iptables-save | grep -q "$rule") || (echo "Adding rule \"$rule\"" && eval "iptables $rule")
done

iptables --policy INPUT DROP
