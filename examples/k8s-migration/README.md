## Prereqs:

1. User role allows creation of pod in pvc namespace
2. Clusters can use public images
3. User has read/write access to pvc
4. No pods mount the pvc
5. Run command from location that has access to both cluster apis
6. 'pv' and 'kubectl' commands installed

e.g usage:

SOURCE_KUBECONFIG=~/.kube/config_microk8s \
SOURCE_NAMESPACE=default \
SOURCE_PVC_NAME=mysql-pv-claim \
DEST_KUBECONFIG=~/.kube/config_magnum \
DEST_NAMESPACE=default \
DEST_PVC_NAME=mysql-pv-claim \
./migrate-pvc.sh