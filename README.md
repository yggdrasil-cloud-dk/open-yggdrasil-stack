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

### 3. Deploy All-in-one
```
make dev-up ENV=aio
```


## OPTIONAL

### 4. Create your own inventory for deployment
```
cp -r ansible/inventory/aio ansible/inventory/<env_name>
vim ansible/inventory/<env_name>
make dev-up ENV=<env_name>
```
