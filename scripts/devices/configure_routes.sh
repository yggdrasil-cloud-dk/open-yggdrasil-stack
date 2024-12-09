#!/bin/bash

cat > /etc/systemd/system/network_routes.service <<EOF
[Unit]
Description=Network routes for openstack deployment
After=network.target

[Service]
ExecStart=/bin/bash -c "ip route replace $OPENSTACK_MGMT_NET via $NETWORK_PRIMARY_GATEWAY_IP"
ExecStart=/bin/bash -c "ip route replace $CEPH_PUBLIC_NET via $NETWORK_PRIMARY_GATEWAY_IP"
ExecStart=/bin/bash -c "ip route replace $NETWORK_PROVIDER_NET via $NETWORK_PROVIDER_GATEWAY_IP"
Type=oneshot

[Install]
WantedBy=default.target
RequiredBy=network.target
EOF

systemctl daemon-reload
systemctl restart network_routes.service
systemctl enable network_routes.service