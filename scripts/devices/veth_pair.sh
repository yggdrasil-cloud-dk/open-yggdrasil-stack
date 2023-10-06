#!/bin/bash

set -xe

sudo apt install -y net-tools

ifconfig veth1 || bash -s <<EOF
set -xe
ip link add veth1 type veth peer name veth2
ip addr add 192.168.1.1/24 dev veth2
ip link set veth1 up
ip link set veth2 up

iptables -t nat -A POSTROUTING -o $(ip r | grep ^default | head -n 1 | grep -o "dev .*" | cut -d ' ' -f 2) -j MASQUERADE
EOF


