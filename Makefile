# TODO: Write status to make_state, do like vagrant hosts file?


TAGS = 

#########
# Setup #
#########

01-configure-network.done:
	scripts/configure-network.sh
	touch $@

02-install-system-deps.done: 01-configure-network.done
	scripts/install-sys-deps.sh
	touch $@

09-configure-loop-devices.done: 02-install-system-deps.done
	scripts/configure-loop-devices.sh
	touch $@

10-install-cephadm.done: 09-configure-loop-devices.done
	scripts/install-cephadm.sh
	touch $@

11-deploy-cephadm.done: 10-install-cephadm.done
	scripts/deploy-cephadm.sh
	touch $@

12-create-pools.done: 11-deploy-cephadm.done
	scripts/create-pools.sh
	touch $@

20-install-kolla-ansible-deps.done: 12-create-pools.done
	scripts/install-kolla-ansible-deps.sh
	touch $@

21-install-kolla-ansible.done: 20-install-kolla-ansible-deps.done
	scripts/install-kolla-ansible.sh
	touch $@

22-configure-kolla-ansible.done: 21-install-kolla-ansible.done
	scripts/configure-kolla-ansible.sh
	touch $@

23-bootstrap-kolla-ansible.done: 22-configure-kolla-ansible.done
	scripts/kolla-ansible.sh bootstrap-servers
	touch $@

24-prechecks-kolla-ansible.done: 23-bootstrap-kolla-ansible.done
	scripts/kolla-ansible.sh prechecks
	touch $@

25-deploy-kolla-ansible.done: 24-prechecks-kolla-ansible.done
	scripts/kolla-ansible.sh deploy
	touch $@

26-postdeploy-kolla-ansible.done: 25-deploy-kolla-ansible.done
	scripts/kolla-ansible.sh post-deploy
	touch $@

31-install-os-client.done: 26-postdeploy-kolla-ansible.done
	scripts/install-os-client.sh
	touch $@

32-create-initial-resources.done: 31-install-os-client.done
	scripts/create-initial-resources.sh
	touch $@

########
# Util #
########

# print vars
print-%  : ; @echo $* = $($*)

# ping nodes
ping-nodes:
	scripts/ping-nodes.sh

deploy-kolla-ansible-tags:
	scripts/kolla-ansible.sh deploy -t $(TAGS)

reconfigure-kolla-ansible-tags:
	scripts/kolla-ansible.sh reconfigure -t $(TAGS)

destroy-cephadm:
	scripts/destroy-cephadm.sh
	rm -rf 10-install-cephadm.done 11-deploy-cephadm.done

destroy-loop-devices:
	scripts/destroy-loop-devices.sh
	rm -rf 09-configure-loop-devices.done

# Get all targets except "clean" and delete their files
clean:
	-rm $$(ls | grep ".*\.done" | grep -v 01-configure-network)   # excluding configure network because its a pain to lose connection

#TODO: clean things here and make it noice
clean-all: clean
	-scripts/kolla-ansible.sh destroy 
	-docker rm -f $$(docker ps -aq)
	-docker volume rm -f $$(docker volume ls -q)
	-ip addr del 10.0.10.100/32 dev openstack_mgmt
	# why are we using /etc/kolla? and /run/libvirt?
	-rm -rf workspace /etc/kolla /run/libvirt
	-ls /sys/class/net | grep -v "eno\|ceph\|neutron\|openstack\|lo\|docker"| xargs -I% ip link delete %
	-scripts/destroy-cephadm.sh
	-scripts/destroy-loop-devices.sh
