# TODO: Write status to make_state, do like vagrant hosts file?


DONE_FILES = 01-configure-network 10-install-deps 20-install-kolla-ansible 30-configure-kolla-ansible 40-deploy-kolla-ansible
$(DONE_FILES): %: %.done

TAGS = 

#########
# Setup #
#########

01-configure-network.done:
	scripts/configure-network.sh
	touch $@

10-install-deps.done: 01-configure-network.done
	scripts/install-dependencies.sh
	touch $@

20-install-kolla-ansible.done: 10-install-deps.done
	scripts/install-kolla-ansible.sh
	touch $@

30-configure-kolla-ansible.done: 20-install-kolla-ansible.done
	scripts/configure-kolla-ansible.sh
	touch $@

40-bootstrap-kolla-ansible.done: 30-configure-kolla-ansible.done
	scripts/kolla-ansible.sh bootstrap-servers
	touch $@

45-prechecks-kolla-ansible.done: 40-bootstrap-kolla-ansible.done
	scripts/kolla-ansible.sh prechecks
	touch $@

50-deploy-kolla-ansible.done: 45-prechecks-kolla-ansible.done
	scripts/kolla-ansible.sh deploy
	touch $@

51-postdeploy-kolla-ansible.done: 50-deploy-kolla-ansible.done
	scripts/kolla-ansible.sh post-deploy
	touch $@

52-install-os-client.done: 51-postdeploy-kolla-ansible.done
	scripts/install-os-client.sh
	touch $@

53-upload-images.done: 52-install-os-client.done
	scripts/upload-images.sh
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

# Get all targets except "clean" and delete their files
clean:
	-rm $$(ls | grep ".*\.done" | grep -v 01-configure-network)   # excluding configure network because its a pain to lose connection

#TODO: clean things here and make it noice
clean-all: clean
	#- scripts/kolla-ansible.sh destroy 
	-docker rm -f $$(docker ps -aq)
	-docker volume rm -f $$(docker volume ls -q)
	-ip addr del 10.0.10.100/32 dev openstack_mgmt
	# why are we using /etc/kolla? and /run/libvirt?
	-rm -rf workspace /etc/kolla /run/libvirt  
