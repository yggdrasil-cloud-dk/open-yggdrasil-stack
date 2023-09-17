#!/bin/bash

set -x
apt install -y tox qemu-utils kpartx ntp

if [ ! -d "sahara-image-elements" ]; then
    git clone --branch stable/2023.1 https://opendev.org/openstack/sahara-image-elements
    cd sahara-image-elements
    git apply ../sahara-image-elements.patch
    cd ..
fi

cd sahara-image-elements
#DIB_DEBUG_TRACE=1 DIB_SPARK_VERSION=3.5.0 DIB_CDH_VERSION=5.11 SPARK_HADOOP_DL=hadoop3 PLUGIN=vanilla HADOOP_VERSION=3.0.1 tox -e venv -- sahara-image-create
#DIB_DEBUG_TRACE=1 DIB_SPARK_VERSION=3.5.0 DIB_CDH_VERSION=5.11 SPARK_HADOOP_DL=hadoop3  HADOOP_VERSION=3.0.1 BASE_IMAGE_OS=ubuntu tox -e venv -- sahara-image-create
DIB_DEBUG_TRACE=1 DIB_RELEASE=jammy HADOOP_VERSION=3.0.1 PLUGIN=vanilla BASE_IMAGE_OS=ubuntu tox -e venv -- sahara-image-create
