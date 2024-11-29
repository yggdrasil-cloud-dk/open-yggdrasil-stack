#!/bin/bash

DOCKER_IMAGES_TAR_FILE_PATH=${DOCKER_IMAGES_TAR_FILE_PATH:-/mnt/winshare/docker_images_2024.1.tar}
DOCKER_IMAGES_LIST_FILE_PATH=${DOCKER_IMAGES_LIST_FILE_PATH:-/mnt/winshare/docker_images_2024.1.list}

docker load -i $DOCKER_IMAGES_TAR_FILE_PATH

while read REPOSITORY TAG IMAGE_ID
do
        echo "== Tagging $REPOSITORY $TAG $IMAGE_ID =="
        docker tag "$IMAGE_ID" "$REPOSITORY:$TAG"
done < $DOCKER_IMAGES_LIST_FILE_PATH
