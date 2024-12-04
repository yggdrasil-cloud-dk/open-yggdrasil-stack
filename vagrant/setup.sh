#!/bin/bash

set -xe

vagrantfile_path=$(pwd)/$(dirname $0)/Vagrantfile


# install packages
sudo apt update
sudo apt install -y virt-manager vagrant

# install vagrant plugins
vagrant plugin install vagrant-libvirt
vagrant plugin install vagrant-mutate

# add user to libvirt group
sudo usermod --append --groups libvirt $USER

# ensure vagrant directors have correct owner
sudo chown -R $USER ~/.vagrant.d/ 

cat <<EOF
---

Now you can run "vagrant up"
EOF



