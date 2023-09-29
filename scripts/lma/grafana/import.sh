#!/bin/bash

set -xe

admin_pass=$(docker exec -it  grafana cat /etc/grafana/grafana.ini | grep ^admin_password | awk '{print $3}')
admin_pass=${admin_pass%%[[:cntrl:]]}

dir=$(dirname "$0")

for jsonfile_no_dashboard_key in $(find $dir -iname "*.json"); do

  dashboard_jsonfile=/tmp/dashboard.json
  
  echo "{ \"dashboard\": $(cat $jsonfile_no_dashboard_key) }" > $dashboard_jsonfile
  sed -i '/^  "version"/d; /^  "id"/d' $dashboard_jsonfile

  dashboard_id=$(cat $dashboard_jsonfile | jq -r .dashboard.uid)
  
  curl -fs http://admin:$admin_pass@10.0.10.1:3000/api/dashboards/uid/$dashboard_id -o /dev/null || curl http://admin:$admin_pass@10.0.10.1:3000/api/dashboards/import -X POST -H "Content-Type: application/json" -d @$dashboard_jsonfile
  
done
