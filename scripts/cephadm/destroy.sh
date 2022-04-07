#!/bin/bash

# Based on https://docs.ceph.com/en/octopus/install/ceph-deploy/quick-ceph-deploy/

set -x

fsid=$(docker ps --format "{{.Names}}" | grep "ceph-.*-mon" | sed 's/ceph-//g;s/-mon.*//g')

#Get information about hosts in the cluster
bootstrap=$(hostname)
hosts=$(cephadm shell --fsid $fsid -c /etc/ceph/ceph.conf -k /etc/ceph/ceph.client.admin.keyring ceph orch host ls --format yaml | grep hostname |  cut -d " " -f2)

#Clean Bootstrap node
echo "Purge cluster in $bootstrap:"
cephadm rm-cluster --fsid $fsid --force
rm -rf /etc/ceph/*
rm -rf /var/log/ceph/*
rm -rf /var/lib/ceph/$fsid

# Clean the rest of hosts
for host in $hosts
do
	if [ $host != $bootstrap ]
		then
			echo "Purge cluster in $host:"
			ceph orch host rm $host
			cephadm_in_host=$(ssh -o StrictHostKeyChecking=no $host ls /var/lib/ceph/$fsid/cephadm*)
			ssh -o StrictHostKeyChecking=no $host python3 $cephadm_in_host rm-cluster --fsid $fsid --force
			# Remove ceph target
			ssh -o StrictHostKeyChecking=no $host bash -c 'systemctl stop ceph*'
			ssh -o StrictHostKeyChecking=no $host bash -c 'systemctl disable ceph*'
			ssh -o StrictHostKeyChecking=no $host bash -c 'rm -rf /etc/systemd/system/ceph*'
			ssh -o StrictHostKeyChecking=no $host systemctl daemon-reload
			ssh -o StrictHostKeyChecking=no $host systemctl reset-failed
			# Remove ceph logs
			ssh -o StrictHostKeyChecking=no $host rm -rf /var/log/ceph/*
			# Remove config files
			rm -rf /var/lib/ceph/$fsid
		fi
done

# remove repo
cephadm rm-repo

# remove ceph-common
apt remove --purge -y ceph-common cephadm

# remove unused dependencies
apt -y autoremove

rm -f /root/cephadm_*