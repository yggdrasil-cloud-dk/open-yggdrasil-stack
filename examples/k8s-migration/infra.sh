#!/bin/bash

cat > /tmp/user_data.sh <<EOF
#!/bin/bash

set -x

snap install microk8s --classic
snap install kubectl --classic

cd /root 
mkdir -p .kube/ /home/ubuntu/.kube

microk8s status --wait-ready

microk8s config | tee .kube/config
microk8s config | tee /home/ubuntu/.kube/config

while ! kubectl get nodes | tail -n 1 | awk '{print \$2}' | grep ^Ready$; do sleep 5; done

sleep 10

git clone https://github.com/kubernetes-csi/csi-driver-host-path.git
cd csi-driver-host-path/deploy/kubernetes-latest
export KUBELET_DATA_DIR=/var/snap/microk8s/common/var/lib/kubelet
./deploy.sh

cat <<EOT | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: csi-hostpath-sc
provisioner: hostpath.csi.k8s.io
reclaimPolicy: Delete
volumeBindingMode: Immediate
allowVolumeExpansion: true
EOT

kubectl patch storageclass csi-hostpath-sc -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

EOF

server_name=microk8s
openstack server show $server_name || ( openstack server create $server_name --flavor m1.medium --network demo-net --image jammy-server-cloudimg-amd64 --key mykey --user-data /tmp/user_data.sh && sleep 10 )
addresses=$(openstack server show microk8s -f value -c addresses | sed "s/'/\"/g" | jq -r .[][] | xargs | sed 's/ /|/g')
openstack floating ip list | egrep "($addresses)" || (
  openstack floating ip list -f value | grep None || openstack floating ip create public1
  fip=$(openstack floating ip list -f value | grep None | awk '{print $2}')
  openstack server add floating ip $server_name $fip
)
openstack security group show open_tcp || ( openstack security group create open_tcp && openstack security group rule create --protocol tcp open_tcp )
openstack server add security group $server_name open_tcp || true