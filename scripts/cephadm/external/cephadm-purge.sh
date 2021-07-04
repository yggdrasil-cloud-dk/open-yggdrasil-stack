#!/bin/bash
display_usage() {
	echo "The ceph cluster fsid must be provided"
	echo -e "\nUsage: $0 <fsid> \n"
	}

if [ -z $1 ]
then
  display_usage
  exit 1
fi
fsid=$1

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
			cephadm_in_host=$(ssh -o StrictHostKeyChecking=no $host ls /var/lib/ceph/$fsid/cephadm*)
			ssh -o StrictHostKeyChecking=no $host python3 $cephadm_in_host rm-cluster --fsid $fsid --force
			# Remove ceph target
			ssh -o StrictHostKeyChecking=no $host systemctl stop ceph.target
			ssh -o StrictHostKeyChecking=no $host systemctl disable ceph.target
			ssh -o StrictHostKeyChecking=no $host rm /etc/systemd/system/ceph.target
			ssh -o StrictHostKeyChecking=no $host systemctl daemon-reload
			ssh -o StrictHostKeyChecking=no $host systemctl reset-failed
			# Remove ceph logs
			ssh -o StrictHostKeyChecking=no $host rm -rf /var/log/ceph/*
			# Remove config files
			rm -rf /var/lib/ceph/$fsid
		fi
done
