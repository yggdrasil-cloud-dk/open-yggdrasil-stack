#!/bin/bash

set -xe

cd custom_exporter

./docker_build.sh

docker ps | grep -q custom_exporter || ./docker_run.sh

cd ..

cat > workspace/etc/kolla/config/prometheus/prometheus.yml.d/custom.yml <<EOF
scrape_configs:
  - job_name: custom
    static_configs:
      - targets:
        - '$(ip --json address show openstack_mgmt | jq -r .[0].addr_info[0].local):8080'
EOF

pstree | grep -q docker.sh || (./scripts/lma/custom_metrics/docker.sh &)
