# Prerequisites #

### On local Computer: ###

1. Setup server from OVH or Hetzner GUI with password authentication

2. On local computer, ensure os01 (for OVH) and os02 (for Hetzner) is added: 
```
grep -q os01 ~/.ssh/config || cat >> ~/.ssh/config <<EOF

# ovh
Host os01
    Hostname 188.165.251.200
	User ubuntu
EOF
grep -q os02 ~/.ssh/config || cat >> ~/.ssh/config <<EOF

# hetzner
Host os02
    Hostname 138.201.130.112
	User root
EOF
```

3. Clone this repo
```
git clone git@bitbucket.org:mgindi/kolla-deploy.git && cd kolla-deploy
```

4. Run script to setup remote server
```
./setup_remote_os_server.sh os02
```

### On Remote Server: ###

5. Run
```
bash -s <<EOF
set -xe
apt update
apt install -y git make ansible bash-completion
ansible-galaxy collection install ansible.netcommon:2.5.1
echo "set -g history-limit 10000" >> ~/.tmux.conf
echo "set paste" >> ~/.vimrc
cd ~
GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" git clone git@bitbucket.org:mgindi/kolla-deploy.git
cd kolla-deploy
git config --global user.email "mo.gindi@gmail.com"
git config --global user.name "Mohamed El Gindi"
EOF

cd kolla-deploy
tmux
```
