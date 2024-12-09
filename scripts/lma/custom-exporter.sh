#!/bin/bash

set -xe

cd custom_exporter

./docker_build.sh

docker ps | grep -q custom_exporter || ./docker_run.sh


service=docker-custom-metrics
cat > /etc/systemd/system/$service.service << EOF
[Unit]
After=docker.service

[Service]
ExecStart=/bin/bash -c "mkdir -p /tmp/custom_metrics && ls -d /opt/custom_metrics/* | xargs -I% bash % &"

[Install]
WantedBy=default.target
EOF

systemctl daemon-reload
systemctl restart $service
systemctl enable $service


exit 0
