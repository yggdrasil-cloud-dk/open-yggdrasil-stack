# TODO: Write status to make_state, do like vagrant hosts file?


DONE_FILES = 01-configure-network 10-install-deps 20-install-kolla-ansible 30-configure-kolla-ansible 40-deploy-kolla-ansible
$(DONE_FILES): %: %.done

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

40-deploy-kolla-ansible.done: 30-configure-kolla-ansible.done
	scripts/deploy-kolla-ansible.sh
	touch $@

########
# Util #
########

# print vars
print-%  : ; @echo $* = $($*)

# ping nodes
ping-nodes:
	scripts/ping-nodes.sh

# Get all targets except "clean" and delete their files
clean:
	@rm $$(ls | grep ".*\.done" | grep -v 01-configure-network)   # excluding configure network because its a pain to lose connection

clean-all: clean
	@rm -rf workspace
