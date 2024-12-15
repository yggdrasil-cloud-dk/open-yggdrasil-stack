#!/bin/bash

set -xe

# install prereqs
sudo apt update && sudo apt-get install -y gnupg software-properties-common

# add hashicorp gpg key
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

# add package repo
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

# update
sudo apt update

# install terraform
sudo apt-get install terraform