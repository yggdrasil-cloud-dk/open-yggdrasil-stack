# TODO: Write status to make_state, do like vagrant hosts file?


DONE_FILES= 10-install-deps 20-install-kolla-ansible 30-configure-kolla-ansible
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

########
# Util #
########

ping-nodes:
	scripts/ping-nodes.sh

# Get all targets except "clean" and delete their files
clean:
	@rm $$(ls | grep ".*\.done")
