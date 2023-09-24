#!/bin/bash

set -xe

admin_pass=$(docker exec -it  grafana cat /etc/grafana/grafana.ini | grep ^admin_password | awk '{print $3}')
admin_pass=${admin_pass%%[[:cntrl:]]}

dashboard_jsonfile=$(dirname "$0")/openstack-dashboard.json
dashboard_id=$(cat $dashboard_jsonfile | jq -r .dashboard.uid)

curl -fs http://admin:$admin_pass@10.0.10.1:3000/api/dashboards/uid/$dashboard_id -o /dev/null || curl http://admin:$admin_pass@10.0.10.1:3000/api/dashboards/import -X POST -H "Content-Type: application/json" -d @$dashboard_jsonfile
