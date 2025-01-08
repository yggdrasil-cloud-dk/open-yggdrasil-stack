#!/bin/bash

set -x

export SRC_KUBECONFIG=~/.kube/config-src
export SRC_NAMESPACE=prod
export SRC_PVC_NAME=app-data
export DST_KUBECONFIG=~/.kube/config-dst
export DST_NAMESPACE=prod
export DST_PVC_NAME=app-data

curl -s https://raw.githubusercontent.com/mogindi/easy-migrate-pvc/main/easy-migrate-pvc.sh | bash