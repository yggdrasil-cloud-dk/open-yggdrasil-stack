#!/bin/bash

set -x

########
# Loop #
########

# disable and remove service
systemctl disable loop-device
rm -f /etc/systemd/system/loop-device.service

# remove lvs
lvremove -y /dev/vg-0/lv-0  /dev/vg-1/lv-1  /dev/vg-2/lv-2

# remove vgs
vgremove -y vg-0 vg-1 vg-2

# remove pvs
pvremove -y /dev/loop10 /dev/loop11 /dev/loop12

# remove loopback devices
losetup -D

cd /mnt

# remove disk image files
rm disk-0.img disk-1.img disk-2.img

###########
# Network #
###########

# delete network configs
systemctl disable internet-access-bridge
rm -f /opt/revive_internet_access.sh /etc/systemd/system/internet-access-bridge.service 
