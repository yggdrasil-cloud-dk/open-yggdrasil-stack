#!/bin/bash

set -xe

# install some packages that may be missing
apt install -y dnsutils net-tools lvm2 openssh-server bridge-utils curl docker.io

# TODO: RUN ONLY ON CONTROLLER

# add user to sudoers
# TODO: sometimes USERNAME is empty.. so hangs
grep -q $USERNAME /etc/sudoers || cat >> /etc/sudoers << EOF

$USERNAME ALL=(ALL) NOPASSWD: ALL
EOF

# add aliases and sources for quick access
grep -q "script_managed" ~/.bashrc || cat >> ~/.bashrc << EOF

# script_managed

alias os='openstack'
alias ossl='openstack server list'
alias osss='openstack server show'
alias osnl='openstack network list'
alias osns='openstack network show'
alias osvl='openstack volume list'
alias osvs='openstack volume show'
alias osrl='openstack router list'
alias osrs='openstack router show'

alias source-venv='source ~/kolla-deploy/workspace/kolla-venv/bin/activate'
alias source-rc='source ~/kolla-deploy/workspace/etc/kolla/admin-openrc.sh'

if [[ \$USER != 'root' ]]; then
    sudo -sE
fi

if [[ -f ~/kolla-deploy/workspace/kolla-venv/bin/activate ]]; then
    source ~/kolla-deploy/workspace/kolla-venv/bin/activate
fi

if [[ -f ~/kolla-deploy/workspace/etc/kolla/admin-openrc.sh ]]; then
    source ~/kolla-deploy/workspace/etc/kolla/admin-openrc.sh
fi
EOF
