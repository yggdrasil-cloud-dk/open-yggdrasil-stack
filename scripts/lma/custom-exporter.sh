#!/bin/bash

set -xe

cd custom_exporter

./docker_build.sh

docker ps | grep -q ce1 || ./docker_run.sh

cd ..

cat > workspace/etc/kolla/config/prometheus/prometheus.yml.d/custom.yml <<EOF
scrape_configs:
  - job_name: custom
    static_configs:
      - targets:
        - 'os01:8080'
EOF

ps | grep -q docker.sh || (./scripts/lma/custom_metrics/docker.sh &)
