#!/bin/bash

set -xe

cd ~

sudo apt update
sudo apt install -y virt-manager vagrant

vagrant plugin install vagrant-libvirt
vagrant plugin install vagrant-mutate

cp $(dirname $0)/Vagrantfile .

sudo vagrant up