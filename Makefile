# TODO: Write status to make_state, do like vagrant hosts file?


TAGS = 

#########
# Setup #
#########

prepare-ansible:
	ln -sfr ansible/inventory/hosts /etc/ansible/hosts

devices-configure:
	ansible-playbook ansible/devices.yml

cephadm-deploy:
	ansible-playbook ansible/cephadm.yml

# kolla-ansible #

kollaansible-prepare:
	ansible-playbook ansible/kolla_ansible.yml

kollaansible-bootstrap:
	scripts/kolla-ansible/kolla-ansible.sh bootstrap-servers

kollaansible-prechecks:
	scripts/kolla-ansible/kolla-ansible.sh prechecks

kollaansible-deploy:
	scripts/kolla-ansible/kolla-ansible.sh deploy

kollaansible-postdeploy:
	scripts/kolla-ansible/kolla-ansible.sh post-deploy

# openstack #

os-client-install:
	scripts/openstack/install-client.sh

os-resources-init:
	scripts/openstack/init-resources.sh

os-images-upload:
	scripts/openstack/upload-images.sh

########
# Util #
########

all-deploy: prepare-ansible devices-configure cephadm-deploy kollaansible-prepare kollaansible-bootstrap kollaansible-prechecks kollaansible-deploy

kollaansible-all-deploy: kollaansible-prepare kollaansible-bootstrap kollaansible-prechecks kollaansible-deploy

all-postdeploy: kollaansible-postdeploy os-client-install os-resources-init os-images-upload

# print vars
print-%  : ; @echo $* = $($*)

# ping nodes
ping-nodes:
	scripts/ping-nodes.sh

kollaansible-tags-deploy:
	scripts/kolla-ansible/kolla-ansible.sh deploy -t $(TAGS)

kollaansible-tags-reconfigure:
	scripts/kolla-ansible/kolla-ansible.sh reconfigure -t $(TAGS)

kollaansible-destroy:
	scripts/kolla-ansible/kolla-ansible.sh destroy --yes-i-really-really-mean-it

cephadm-destroy:
	ansible-playbook ansible/cephadm.yml -t destroy

devices-destroy:
	ansible-playbook ansible/devices.yml -t destroy

os-resources-destroy:
	scripts/openstack/destroy-resources.sh

clean: kollaansible-destroy cephadm-destroy devices-destroy
	rm -rf workspace
	@echo -e "-----\nPLEASE REBOOT NODES\n-----"
