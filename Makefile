# TODO: Write status to make_state, do like vagrant hosts file?


TAGS = 

#########
# Setup #
#########

# devices #

01-devices-deps.done:
	scripts/devices/deps.sh
	touch $@

02-devices-network.done: 01-devices-deps.done
	scripts/devices/network.sh
	touch $@

03-devices-loop.done: 02-devices-network.done
	scripts/devices/loop.sh
	touch $@

# cephadm #

10-cephadm-install.done: 03-devices-loop.done
	scripts/cephadm/install.sh
	touch $@

11-cephadm-deploy.done: 10-cephadm-install.done
	scripts/cephadm/deploy.sh
	touch $@

12-cephadm-pools.done: 11-cephadm-deploy.done
	scripts/cephadm/pools.sh
	touch $@

# kolla-ansible #

20-kolla-ansible-deps.done: 12-cephadm-pools.done
	scripts/kolla-ansible/deps.sh
	touch $@

21-kolla-ansible-install.done: 20-kolla-ansible-deps.done
	scripts/kolla-ansible/install.sh
	touch $@

22-kolla-ansible-configure.done: 21-kolla-ansible-install.done
	scripts/kolla-ansible/configure.sh
	touch $@

23-kolla-ansible-bootstrap.done: 22-kolla-ansible-configure.done
	scripts/kolla-ansible/kolla-ansible.sh bootstrap-servers
	touch $@

24-kolla-ansible-prechecks.done: 23-kolla-ansible-bootstrap.done
	scripts/kolla-ansible/kolla-ansible.sh prechecks
	touch $@

25-kolla-ansible-deploy.done: 24-kolla-ansible-prechecks.done
	scripts/kolla-ansible/kolla-ansible.sh deploy
	touch $@

26-kolla-ansible-postdeploy.done: 25-kolla-ansible-deploy.done
	scripts/kolla-ansible/kolla-ansible.sh post-deploy
	touch $@

# util #

30-install-os-client.done: 26-kolla-ansible-postdeploy.done
	scripts/install-os-client.sh
	touch $@

31-init.done: 30-install-os-client.done
	scripts/init.sh
	touch $@

########
# Util #
########

# print vars
print-%  : ; @echo $* = $($*)

# ping nodes
ping-nodes:
	scripts/ping-nodes.sh

kolla-ansible-deploy-tags:
	scripts/kolla-ansible/kolla-ansible.sh deploy -t $(TAGS)

kolla-ansible-reconfigure-tags:
	scripts/kolla-ansible/kolla-ansible.sh reconfigure -t $(TAGS)

refresh-done-flags:
	ls | grep "^[0-9]" | xargs -I % touch %

cephadm-destroy:
	scripts/cephadm/destroy.sh
	rm -f 10-* 11-* 12-*

devices-loop-destroy:
	scripts/devices/destroy-loop.sh
	rm -f 03-*

# Get all targets with '.done' and delete their files
clean:
	-rm $$(ls | grep ".*\.done")

#TODO: clean things here and make it noice
clean-all: clean
	-scripts/kolla-ansible/kolla-ansible.sh destroy 
	-docker rm -f $$(docker ps -aq | grep -v ceph)
	-docker volume rm -f $$(docker volume ls -q)
	-ip addr del 10.0.10.100/32 dev openstack_mgmt
	# why are we using /etc/kolla? and /run/libvirt?
	-rm -rf workspace /etc/kolla /run/libvirt
	-ls /sys/class/net | grep -v "eno\|ceph\|neutron\|openstack\|lo\|docker"| xargs -I% ip link delete %
	-scripts/cephadm/destroy.sh
	-scripts/devices/destroy-loop.sh
