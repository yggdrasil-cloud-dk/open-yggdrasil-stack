#!/bin/bash

set -xe

#TODO: this shouldn't be here. It needs to be done once when settup up host
#BACKEND_DEVICE=/dev/sdb
#
## format backend device
#mkfs.ext4 $BACKEND_DEVICE
#
## mount backend device
#mount $BACKEND_DEVICE /mnt

# change dir
cd /mnt

# create image files
truncate -s 200G disk-0.img
truncate -s 200G disk-1.img
truncate -s 200G disk-2.img

# create loop devices
losetup /dev/loop10 disk-0.img
losetup /dev/loop11 disk-1.img
losetup /dev/loop12 disk-2.img

# create pvs
pvcreate /dev/loop10
pvcreate /dev/loop11
pvcreate /dev/loop12

# create vgs
vgcreate vg-0 /dev/loop10
vgcreate vg-1 /dev/loop11
vgcreate vg-2 /dev/loop12

# create lvms
lvcreate -n lv-0 -l 100%FREE vg-0
lvcreate -n lv-1 -l 100%FREE vg-1
lvcreate -n lv-2 -l 100%FREE vg-2

# lvms will be at path /dev/vg-X/lv-X
