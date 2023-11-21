#!/bin/bash

server=$1

# user is only initial user to connection
if [[ $server == os01 ]]; then
  user=ubuntu
elif [[ $server == os02 ]]; then
  user=root
fi


if [[ -z $user ]] || [[ -z $server ]]; then
  echo missing vars
  exit 1
fi

set -x 
> .ssh/known_hosts
ssh-copy-id -o "StrictHostKeyChecking=no" $user@$server
ssh $user@$server 'sudo cp ~/.ssh/authorized_keys /root/.ssh/authorized_keys'

ssh $server bash -s <<EOF
set -x

find /etc/ssh/sshd_config* -type f | xargs sed -i 's/*PasswordAuthentication yes/PasswordAuthentication no/g'
rm -f /etc/ssh/sshd_config.d/50-cloud-init.conf
systemctl restart sshd
hostname $server
echo $server | tee /etc/hostname
EOF
