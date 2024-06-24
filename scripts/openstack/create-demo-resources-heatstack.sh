#!/bin/bash

# Based on https://docs.openstack.org/kolla-ansible/latest/user/quickstart.html

set -xe

# source venv
cd workspace
source kolla-venv/bin/activate

CONFIG_DIR=$(pwd)/etc/kolla

# source admin rc
. $CONFIG_DIR/admin-openrc.sh

cat > /tmp/demo-stack.yml << EOF
heat_template_version: 2021-04-16

description: Simple template to deploy a single PostgreSQL instance

parameters:
  network_name:
    type: string
    default: demo-net

resources:

  private_network_port: 
    type: OS::Neutron::Port
    properties:
      network_id: { get_param: network_name }
      security_groups: [ default ]

  my_db_instance:
    type: OS::Trove::Instance
    properties:
      flavor: ds2G
      size: 5
      networks: [{ network: { get_param: network_name } }]
      databases: [{ name: test }]
      users: [{"name": userA, "password": password, "databases": [test] }]
      datastore_type: postgresql
      datastore_version: "12.18"
      replica_count: 1

  my_file_share:
    type: OS::Manila::Share
    properties:
      access_rules: [{"access_to": 0.0.0.0/0, "access_type": ip, "access_level": rw }]
      is_public: false
      name: demo-share1
      share_network: demo-share-network1
      share_protocol: NFS
      share_type: default_share_type
      size: 1

  my_instance:
    type: OS::Nova::Server
    properties:
      image: jammy-server-cloudimg-amd64
      flavor: m1.medium
      networks: [{ port: { get_resource: private_network_port } }]
      key_name: testkey
      user_data_format: RAW
      user_data: |
        #!/bin/bash
        apt install -y nfs-common postgresql-client
        #psql -h <ip> test -U userA
        #sudo mount <mount type> /mnt

  floating_ip:
    type: OS::Neutron::FloatingIP
    properties:
      floating_network: public1
      port_id: {get_resource: private_network_port}


EOF

openstack stack show developer-resources && openstack stack update -t /tmp/demo-stack.yml developer-resources || openstack stack create -t /tmp/demo-stack.yml  developer-resources
