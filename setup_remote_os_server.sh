#!/bin/bash

server=$1

# user is only initial user to connection
if [[ $server =~ ovh ]]; then
  user=ubuntu
elif [[ $server =~ hetzner ]]; then
  user=root
fi


if [[ -z $user ]] || [[ -z $server ]]; then
  echo missing vars
  exit 1
fi

another_ssh_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2ChoqYodykOqMHA6JX4b2B9HZGdbTHpshh3Djt7dYAv1PuVNOaJSm7k65pGppRduvx5BeUhOJV73g9Jar4hHb9sbDYyG2eR0knalOqwfyOOEE2WmVy2FXjxXiC3yPDpPh5JyysQ9Y7PRjYdvjHVlV/aFSqbYrYULZQRw0UkLbObu6y/eUQfg26UmeSYax7CUn4YDWe2Nko+XzlR1gH7Vmj1DzlTMdNdRGAoC0w86OQR4gGQfnDLpoWM8k5rOuNvZHW19hF+d6l0avAfUjoGhConuevjA9KMopLmIEHTnpSXTdOsBeaVpKToIjbToNIgTZTVMOrFv+YbP/2fricElr EXT.mohamed.el.gindi@W-PC2319M5"

set -x 
> ~/.ssh/known_hosts
ssh-copy-id -o "StrictHostKeyChecking=no" $user@$server
ssh $user@$server "echo $another_ssh_key | tee -a ~/.ssh/authorized_keys"
ssh $user@$server 'sudo cp ~/.ssh/authorized_keys /root/.ssh/authorized_keys'


ssh $server bash -s <<EOF
set -x

find /etc/ssh/sshd_config* -type f | xargs sed -i 's/*PasswordAuthentication yes/PasswordAuthentication no/g'
rm -f /etc/ssh/sshd_config.d/50-cloud-init.conf
systemctl restart sshd
hostname $server
echo $server | tee /etc/hostname
EOF
