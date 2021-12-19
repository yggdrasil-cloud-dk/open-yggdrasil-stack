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
truncate -s 8G disk-0.img
truncate -s 8G disk-1.img
truncate -s 8G disk-2.img

# create loop devices
losetup /dev/loop100 disk-0.img
losetup /dev/loop101 disk-1.img
losetup /dev/loop102 disk-2.img

# create pvs
pvcreate /dev/loop100
pvcreate /dev/loop101
pvcreate /dev/loop102

# create vgs
vgcreate vg-0 /dev/loop100
vgcreate vg-1 /dev/loop101
vgcreate vg-2 /dev/loop102

# create lvms
# note: lvms will be at path /dev/vg-X/lv-X
lvcreate -n lv-0 -l 100%FREE vg-0
lvcreate -n lv-1 -l 100%FREE vg-1
lvcreate -n lv-2 -l 100%FREE vg-2

# make devices persistent
test -e /etc/systemd/system/loop-device.service || cat > /etc/systemd/system/loop-device.service << EOF
[Unit]

[Service]
Type=oneshot
ExecStart=-/bin/bash -c 'losetup /dev/loop100 /mnt/disk-0.img'
ExecStart=-/bin/bash -c 'losetup /dev/loop101 /mnt/disk-1.img'
ExecStart=-/bin/bash -c 'losetup /dev/loop102 /mnt/disk-2.img'

[Install]
WantedBy=default.target
EOF

systemctl daemon-reload
systemctl enable loop-device

touch /root/loop_devices.done