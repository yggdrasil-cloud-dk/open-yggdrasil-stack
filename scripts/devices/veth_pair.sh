#!/bin/bash

set -xe

sudo apt install -y net-tools

cat > /opt/veth_device.sh <<EOT
#!/bin/bash

ifconfig veth1 || bash -s <<EOF
set -xe
ip link add veth1 type veth peer name veth2
ip addr add $NETWORK_VETH_PAIR_GATEWAY dev veth2
ip link set veth1 up
ip link set veth2 up

iptables -t nat -A POSTROUTING -o $(ip r | grep ^default | head -n 1 | grep -o "dev .*" | cut -d ' ' -f 2) -j MASQUERADE
EOF
EOT

cat > /etc/systemd/system/veth_device.service <<EOF
[Unit]
Description=create veth device for openstack external gateway
After=network.target

[Service]
ExecStart=/bin/bash /opt/veth_device.sh
Type=oneshot

[Install]
WantedBy=default.target
RequiredBy=network.target
EOF

systemctl daemon-reload
systemctl restart veth_device.service
systemctl enable veth_device.service