#!/bin/bash

#ceph mgr module enable prometheus

cat > workspace/etc/kolla/config/prometheus/prometheus.yml.d/ceph.yml <<EOF
scrape_configs:
  - job_name: ceph
    static_configs:
      - targets:
        - '$(ip --json address show ceph_public | jq -r .[0].addr_info[0].local):9283'
EOF
