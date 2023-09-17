#!/bin/bash

apt install -y tox qemu-utils kpartx

git clone --branch stable/2023.1 https://opendev.org/openstack/sahara-image-elements
cd sahara-image-elements

git apply ../sahara-image-elements.patch
DIB_DEBUG_TRACE=1 DIB_SPARK_VERSION=3.5.0 DIB_CDH_VERSION=5.11 SPARK_HADOOP_DL=hadoop3 tox -e venv -- sahara-image-create
