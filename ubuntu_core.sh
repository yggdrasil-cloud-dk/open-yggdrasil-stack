#!/bin/bash


mkdir -p images && cd images
wget https://cdimage.ubuntu.com/ubuntu-core/22/stable/current/ubuntu-core-22-amd64.img.xz
unxz ubuntu-core-22-amd64.img.xz
cp ./ubuntu-core-22-amd64.img /var/lib/libvirt/images/

mkdir -p ubuntu-core && cd ubuntu-core
snap install snapcraft --classic 
# MANUAL STEP: log into snap craft https://ubuntu.com/core/docs/create-ubuntu-one
wget https://raw.githubusercontent.com/canonical/models/refs/heads/master/ubuntu-core-22-amd64.json -O my-model.json
sed -i 's/canonical/Mye3K9SlhgBvBRNlmAvqsdvZDOndfbHP/g' my-model.json
sed -i "s/2022-04-04T10:40:41+00:00/$(date -Iseconds --utc)/" my-model.json
snap sign -k my-model-key my-model.json > my-model.model
snap install ubuntu-image --classic
ubuntu-image snap my-model.model
cat > system-user.json <<EOF
{
  "type": "system-user",
  "authority-id": "Mye3K9SlhgBvBRNlmAvqsdvZDOndfbHP",
  "brand-id": "Mye3K9SlhgBvBRNlmAvqsdvZDOndfbHP",
  "models": ["ubuntu-core-22-amd64"],
  "series": ["16"],
  "email": "mo.gindi@gmail.com",
  "username": "gindi",
  "ssh-keys": [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDvHbFftgNosvB4n5OW/OgTllzMK3jPNmC0G6Z1L9kDhT25eLqLk1/bKPUEkRxQdr+hVXNWMLJACzFEeDWhkA1dhz1+GP6FErL81+cW4thC0PfwHnT6ZxmUvBrWvSMqCv8l3sNSSKb9JWXzWu8jRApA1wB9Y4OWIQceADGnAVTq1AhOTweHL2/oZP/2gqyIb57g2YccDVjARgFCUX01AidmNRyG1N3/rMdBKcyJnMQVVjfp+LNlHnYRMVUGwKtBkrjvI6nMoxuqwb599tk7+m9rF4phSEJ12+mVogservCbnTQmDVnEwYnhlA4oUBCjIrL1YmbeKVihgcpZFjdhTNDa/jqzcxI2JW4EQdjPtUxKLd/kzoLASpLKzD+6QqfwpJnep2tcOvtziZO8gCWCkhh70+oUx6uIVe2vl2br+YarwU1B7A3dNz9fv4U0D8tFxwQZbFvQLHdgfjnAAanuk1qlVYyAIBupyaYuHKbJS/h1OGrYDlihDhHFJHRy0x9cqqc= mogindi@MO-SHINOBEE-1"
  ],
  "since": "2024-05-16T18:06:04+00:00",
  "until": "2064-05-16T18:06:04+00:00"
}
EOF
snap sign -k my-model-key system-user.json --chain > auto-import.assert
losetup -Pf pc.img
device=$(losetup | grep pc.img | awk '{print $1}')
mount $device/p2 /mnt
cp auto-import.assert /mnt
umount /mnt
losetup -d $device


# fix qemu.conf
grep '^security_driver = "none"' /etc/libvirt/qemu.conf || ( 
  echo 'security_driver = "none"' >> /etc/libvirt/qemu.conf
  systemctl restart libvirtd
)
