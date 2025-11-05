# Prerequisites #


### 1. Setup prerequisites
```
apt install -y git make ansible bash-completion
ansible-galaxy collection install ansible.netcommon:2.5.1
```

### 2. Clone
```
git clone git@github.com:yggdrasil-cloud-dk/open-yggdrasil-stack.git
```

### 3. Deploy Dev environment on 2 Vagrant VMs with KVM (all prerequisites installed on the fly)
```
make dev-up
```


## OPTIONAL

### 4. Create your own inventory for deployment
```
cp -r ansible/inventory/aio ansible/inventory/<env_name>
vim ansible/inventory/<env_name>
make all-up all-postdeploy ENV=<env_name>
```
