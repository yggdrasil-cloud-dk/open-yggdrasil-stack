#!/bin/bash

apt install -y fail2ban

iptables-save | grep -q 'INPUT.*--dport 22' || bash -s <<EOF
iptables -P INPUT ACCEPT
iptables -I INPUT 1 -i lo -j ACCEPT
iptables -I INPUT 2 -p icmp -j ACCEPT
iptables -I INPUT 3 -p tcp --dport 22 -j ACCEPT
iptables -I INPUT 4 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -P INPUT DROP
EOF


