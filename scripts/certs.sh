#!/bin/bash

set -xe

apt install -y certbot

iptables -A INPUT -p tcp --dport 80 -j ACCEPT
certbot certonly --non-interactive --standalone -d console.yggdrasilcloud.dk --staple-ocsp -m mo.gindi@gmail.com --agree-tos
while iptables -D INPUT -p tcp --dport 80 -j ACCEPT; do echo removed rule; done || true

