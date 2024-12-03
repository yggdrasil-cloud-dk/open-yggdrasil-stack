#!/bin/bash

#ceph mgr module enable prometheus

cat > workspace/etc/kolla/config/prometheus/prometheus.yml.d/ceph.yml <<EOF
scrape_configs:
  - job_name: ceph
    static_configs:
      - targets:
        - '$CEPH_PUBLIC_IP:9283'
EOF
