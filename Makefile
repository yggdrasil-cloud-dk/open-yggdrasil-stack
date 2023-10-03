SHELL:=/bin/bash

TAGS = 

#########
# Setup #
#########

# TODO: run in ansible so it runs on all nodes
harden:
	cp scripts/hardening/ssh.sh /etc/rc.local
	chmod 755 /etc/rc.local
	systemctl restart rc-local
	systemctl enable rc-local

prepare-ansible:
	mkdir -p /etc/ansible
	ln -sfr ansible/inventory/hosts /etc/ansible/hosts
	ln -sfr ansible/ansible.cfg /etc/ansible/ansible.cfg

devices-configure:
	ansible-playbook ansible/devices.yml

cephadm-deploy:
	ansible-playbook ansible/cephadm.yml

# kolla-ansible #

kollaansible-images:
	ansible-playbook ansible/prepare_images.yml -v

kollaansible-prepare:
	ansible-playbook ansible/kolla_ansible.yml

kollaansible-create-certs:
	scripts/kolla-ansible/kolla-ansible.sh octavia-certificates

kollaansible-bootstrap:
	scripts/kolla-ansible/kolla-ansible.sh bootstrap-servers

kollaansible-prechecks:
	scripts/kolla-ansible/kolla-ansible.sh prechecks

kollaansible-deploy:
	scripts/kolla-ansible/kolla-ansible.sh deploy

kollaansible-postdeploy:
	scripts/kolla-ansible/kolla-ansible.sh post-deploy

kollaansible-lma: 
	scripts/lma/custom-exporter.sh
	scripts/lma/ceph.sh
	scripts/lma/grafana/import.sh
	scripts/lma/prometheus-alerts/copy-rules.sh
	scripts/kolla-ansible/kolla-ansible.sh reconfigure -t prometheus

# TODO REMOVE
prometheus-alerts:
	scripts/lma/prometheus-alerts/copy-rules.sh
	scripts/kolla-ansible/kolla-ansible.sh reconfigure -t prometheus

# openstack #

openstack-client-install:
	scripts/openstack/install-client.sh

openstack-resources-init:
	scripts/openstack/init-resources.sh

openstack-images-upload:
	scripts/openstack/upload-images.sh

symlink-etc-kolla:
	ln -sfr workspace/etc/kolla/* /etc/kolla/

########
# Util #
########

infra-up: harden prepare-ansible devices-configure cephadm-deploy

kollaansible-up: kollaansible-images kollaansible-prepare kollaansible-create-certs kollaansible-bootstrap kollaansible-prechecks kollaansible-deploy kollaansible-lma

all-up: infra-up kollaansible-up

all-postdeploy: kollaansible-postdeploy openstack-client-install openstack-resources-init openstack-images-upload symlink-etc-kolla

# print vars
print-%  : ; @echo $* = $($*)

# ping nodes
ping-nodes:
	scripts/ping-nodes.sh

kollaansible-tags-deploy:
	scripts/kolla-ansible/kolla-ansible.sh deploy -t $(TAGS)

# Set single tag
kollaansible-fromtag-deploy:
	all_tags=$$(grep "^        tags:" workspace/kolla-ansible/ansible/site.yml | sed 's/        tags: //g; s/ }//g; s/,.*//g; s/\[//g' | xargs | sed 's/ /,/g') && \
	remaining_tags=$$(echo $$all_tags | grep -o $(TAGS).*) && \
	scripts/kolla-ansible/kolla-ansible.sh deploy -t $$remaining_tags

kollaansible-tags-reconfigure:
	scripts/kolla-ansible/kolla-ansible.sh reconfigure -t $(TAGS)

kollaansible-destroy:
	scripts/kolla-ansible/kolla-ansible.sh destroy --yes-i-really-really-mean-it
	@echo -e "-----\nPLEASE REBOOT NODES\n-----"; sleep 5

kollaansible-purge: kollaansible-destroy
	@rm -rf workspace

cephadm-destroy:
	ansible-playbook ansible/cephadm.yml -t destroy

devices-destroy:
	ansible-playbook ansible/devices.yml -t destroy

openstack-resources-destroy:
	scripts/openstack/destroy-resources.sh

clean: kollaansible-purge cephadm-destroy devices-destroy
