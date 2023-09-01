## Prerequisites ##

Run:
```
apt install git make ansible bash-completion
ansible-galaxy collection install ansible.netcommon:2.5.1
echo "set -g history-limit 5000" >> ~/.tmux.conf
cd ~
git clone git@bitbucket.org:mgindi/kolla-deploy.git
cd kolla-deploy
git config --global user.email "mo.gindi@gmail.com"
git config --global user.name "Mohamed El Gindi"
tmux

```
