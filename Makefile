# TODO: Write status to make_state, do like vagrant hosts file?


DONE_FILES= 1-install-deps 2-install-kolla-ansible
$(DONE_FILES): %: %.done

#########
# Setup #
#########

1-install-deps.done:
	scripts/install-dependencies.sh
	touch $@

2-install-kolla-ansible.done: 1-install-deps
	scripts/install-kolla-ansible.sh
	touch $@

########
# Util #
########

ping-nodes:
	scripts/ping-nodes.sh

# Get all targets except "clean" and delete their files
clean:
	@rm $$(ls | grep ".*\.done")
