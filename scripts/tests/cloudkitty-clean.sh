#!/bin/bash

set -xe

# source venv
cd workspace
source kolla-venv/bin/activate
source etc/kolla/admin-openrc.sh

CONFIG_DIR=$(pwd)/etc/kolla

for gid in $(cloudkitty hashmap group list -f value | awk '{print $2}'); do
  for mid in $(cloudkitty hashmap mapping list -g $gid -f value | awk '{print $1}'); do
    cloudkitty hashmap mapping delete $mid
  done
  cloudkitty hashmap group delete $gid
done

for sid in $(cloudkitty hashmap service list -f value | awk '{print $2}'); do
  for fid in $(cloudkitty hashmap field list $sid -f value | awk '{print $2}'); do
    cloudkitty hashmap field delete $fid
  done
  cloudkitty hashmap service delete $sid
done

