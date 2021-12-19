# TODO: Write status to make_state, do like vagrant hosts file?


TAGS = 

#########
# Setup #
#########

prepare-ansible:
	ln -sfr ansible/inventory/hosts /etc/ansible/hosts

devices:
	ansible-playbook ansible/devices.yml

cephadm:
	ansible-playbook ansible/cephadm.yml

# kolla-ansible #

kolla-ansible-prepare:
	ansible-playbook ansible/kolla_ansible.yml

kolla-ansible-bootstrap:
	scripts/kolla-ansible/kolla-ansible.sh bootstrap-servers

kolla-ansible-prechecks:
	scripts/kolla-ansible/kolla-ansible.sh prechecks

kolla-ansible-deploy:
	scripts/kolla-ansible/kolla-ansible.sh deploy

kolla-ansible-post-deploy:
	scripts/kolla-ansible/kolla-ansible.sh post-deploy

# openstack #

os-install-client:
	scripts/openstack/install-client.sh

os-init-resources:
	scripts/openstack/init-resources.sh

os-upload-images:
	scripts/openstack/upload-images.sh

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

kolla-ansible-destroy:
	scripts/kolla-ansible/kolla-ansible.sh destroy --yes-i-really-really-mean-it

cephadm-destroy:
	ansible-playbook ansible/cephadm.yml -t destroy

devices-destroy:
	ansible-playbook ansible/devices.yml -t destroy

os-destroy-resources:
	scripts/openstack/destroy-resources.sh

clean: kolla-ansible-destroy cephadm-destroy devices-destroy
	@echo -e "-----\nPLEASE REBOOT NODES\n-----"
