#!/bin/bash

SOURCE_KUBECONFIG=$SOURCE_KUBECONFIG
SOURCE_NAMESPACE=$SOURCE_NAMESPACE
SOURCE_PVC_NAME=$SOURCE_PVC_NAME

DEST_KUBECONFIG=$DEST_KUBECONFIG
DEST_NAMESPACE=$DEST_NAMESPACE
DEST_PVC_NAME=$DEST_PVC_NAME

STARTUP_COMMANDS="apt update && apt install iproute2 -y"

# deploy ubuntu pod in both clusters


set -xe

SOURCE_EXTRA_ARGS="--kubeconfig $SOURCE_KUBECONFIG -n $SOURCE_NAMESPACE"
DEST_EXTRA_ARGS="--kubeconfig $DEST_KUBECONFIG -n $DEST_NAMESPACE"

# Checks
source_pvc_used_by=$(kubectl $SOURCE_EXTRA_ARGS describe pvc $SOURCE_PVC_NAME  | grep "^Used By:" | awk '{print $3}')
test $source_pvc_used_by == "<none>" || ( echo "source pvc used by pod(s) $source_pvc_used_by. Please ensure they are not used. Exiting.." ; exit 1 )
dest_pvc_used_by=$(kubectl $DEST_EXTRA_ARGS describe pvc $DEST_PVC_NAME  | grep "^Used By:" | awk '{print $3}')
test $dest_pvc_used_by == "<none>" || ( echo "dest pvc used by pod(s) $dest_pvc_used_by. Please ensure they are not used. Exiting.." ; exit 1 )


container_name=ubuntu
cat <<EOF | kubectl $SOURCE_EXTRA_ARGS apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: $container_name
spec:
  containers:
  - image: ubuntu
    command:
      - "sleep"
      - "infinity"
    imagePullPolicy: IfNotPresent
    name: ubuntu
    volumeMounts:
    - name: src-pvc
      mountPath: /mnt/
  restartPolicy: Always
  volumes:
  - name: src-pvc
    persistentVolumeClaim:
      claimName: $SOURCE_PVC_NAME
EOF

cat <<EOF | kubectl $DEST_EXTRA_ARGS apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: $container_name
spec:
  containers:
  - image: ubuntu
    command:
      - "sleep"
      - "infinity"
    imagePullPolicy: IfNotPresent
    name: ubuntu
    volumeMounts:
    - name: dest-pvc
      mountPath: /mnt/
  restartPolicy: Always
  volumes:
  - name: dest-pvc
    persistentVolumeClaim:
      claimName: $DEST_PVC_NAME
EOF

# wait for pods to be ready
while kubectl $SOURCE_EXTRA_ARGS get pods $container_name --output="jsonpath={.status.containerStatuses[*].ready}" | grep false; do sleep 5; done
while kubectl $DEST_EXTRA_ARGS get pods $container_name --output="jsonpath={.status.containerStatuses[*].ready}" | grep false; do sleep 5; done

# prepare pods
( kubectl $SOURCE_EXTRA_ARGS exec -it $container_name -- /bin/bash -c "$STARTUP_COMMANDS" ) &
( kubectl $DEST_EXTRA_ARGS exec -it $container_name -- /bin/bash -c "$STARTUP_COMMANDS" ) &
wait
