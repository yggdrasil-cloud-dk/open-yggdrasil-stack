#!/bin/bash

set -xe

if ! mount | grep -q /mnt/winshare; then
  mkdir -p /mnt/winshare
  read -s -p "Enter password: " pass
  mount.cifs -o user=u429780,pass=$pass //u429780.your-storagebox.de/backup /mnt/winshare/
fi

suffix=$(date -I)

DOCKER_IMAGES_TAR_FILE_PATH=${DOCKER_IMAGES_TAR_FILE_PATH:-/mnt/winshare/docker_images_2024.1_${suffix}.tar}
DOCKER_IMAGES_LIST_FILE_PATH=${DOCKER_IMAGES_LIST_FILE_PATH:-/mnt/winshare/docker_images_2024.1_${suffix}.list}

FILTER='$1 ~ /openstack.kolla/ && $2 !~ /none/'

docker images | sed '1d' | awk "{if ($FILTER) print \$1 \" \" \$2 \" \" \$3}" > $DOCKER_IMAGES_LIST_FILE_PATH

IDS=$(cat $DOCKER_IMAGES_LIST_FILE_PATH | awk "{print \$3}")
docker save $IDS -o $DOCKER_IMAGES_TAR_FILE_PATH





