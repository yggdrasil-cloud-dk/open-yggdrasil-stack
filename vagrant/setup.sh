#!/bin/bash

set -xe


vagrantfile_path=$(pwd)/$(dirname $0)/Vagrantfile

cd ~

sudo apt update
sudo apt install -y virt-manager vagrant

vagrant plugin install vagrant-libvirt
vagrant plugin install vagrant-mutate

rm -f Vagrantfile
cp $vagrantfile_path . 

sudo vagrant up
