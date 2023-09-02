## Prerequisites ##

Run:
```
bash -s <<-EOF
	set -xe
	apt update
	apt install -y git make ansible bash-completion
	ansible-galaxy collection install ansible.netcommon:2.5.1
	echo "set -g history-limit 5000" >> ~/.tmux.conf
	cd ~
	GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" git clone git@bitbucket.org:mgindi/kolla-deploy.git
	cd kolla-deploy
	git config --global user.email "mo.gindi@gmail.com"
	git config --global user.name "Mohamed El Gindi"
	EOF
cd kolla-deploy
tmux
```
