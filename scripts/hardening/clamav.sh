#!/bin/bash

set -x

CLAMAV_VERSION=1.4.1

# installs all dependencies and services
apt install -y clamav

systemctl stop clamav-freshclam.service

# updates binaries
cd /tmp/ && \
wget https://www.clamav.net/downloads/production/clamav-$CLAMAV_VERSION.linux.x86_64.deb && \
dpkg -i clamav-$CLAMAV_VERSION.linux.x86_64.deb

# symlink freshclam
ln -sf  /usr/local/bin/freshclam  /usr/bin/freshclam
ln -sf /etc/clamav/freshclam.conf /usr/local/etc/freshclam.conf

systemctl start clamav-freshclam.service
systemctl enable clamav-freshclam.service
