#!/bin/bash

set -xe

cd custom_exporter

./docker_build.sh

docker ps | grep -q custom_exporter || ./docker_run.sh

cd ..

pstree | grep -q docker.sh || (./scripts/lma/custom_metrics/docker.sh &)
