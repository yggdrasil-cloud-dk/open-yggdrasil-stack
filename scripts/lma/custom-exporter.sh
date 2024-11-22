#!/bin/bash

set -xe

cd custom_exporter

./docker_build.sh

docker ps | grep -q custom_exporter || ./docker_run.sh

cd ..


service=docker-custom-metrics
cat > /etc/systemd/system/$service.service << EOF
[Unit]
After=docker.service

[Service]
ExecStart=-/bin/bash $(pwd)/scripts/lma/custom_metrics/docker.sh

[Install]
WantedBy=default.target
EOF

systemctl daemon-reload
systemctl restart $service
systemctl enable $service


exit 0
