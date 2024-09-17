terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}

data "external" "env" {
  program = ["${path.module}/env.sh"]
}

# Configure the OpenStack Provider
provider "openstack" {
  user_name   = data.external.env.result["os_username"]
  tenant_name = data.external.env.result["os_tenant_name"]
  password    = data.external.env.result["os_password"]
  auth_url    = data.external.env.result["os_auth_url"]
  region      = data.external.env.result["os_region_name"]
}

#---

resource "openstack_networking_secgroup_v2" "secgroup_1" {
  name        = "secgroup_1"
  description = "My neutron security group"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup_1.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_2" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup_1.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_3" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup_1.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup_1.id
}

data "openstack_networking_network_v2" "network" {
  name = "demo-net"
}

resource "openstack_networking_port_v2" "port_1" {
  network_id = data.openstack_networking_network_v2.network.id
}

resource "openstack_networking_port_secgroup_associate_v2" "port_1" {
  port_id = openstack_networking_port_v2.port_1.id
  security_group_ids = [
    openstack_networking_secgroup_v2.secgroup_1.id
  ]
}

resource "openstack_networking_floatingip_v2" "floatip_1" {
  pool = "public1"
}

resource "openstack_networking_floatingip_associate_v2" "fip_1" {
  floating_ip = openstack_networking_floatingip_v2.floatip_1.address
  port_id     = openstack_networking_port_v2.port_1.id
}


resource "openstack_compute_instance_v2" "instance_1" {
  name            = "app_1"
  image_name        = "jammy-server-cloudimg-amd64"
  flavor_name       = "m1.small"
  key_pair        = "testkey"
  security_groups = ["secgroup_1"]
  user_data       = <<-EOF
    #!/bin/bash
    
    set -x
    
    echo ubuntu:ubuntu | chpasswd

    sudo apt update && \
    DEBIAN_FRONTEND=noninteractive sudo apt install -y docker.io docker-compose

    cat > docker-compose.yml <<EOT
    version: "3" 
    # Defines which compose version to use
    services:
      # Services line define which Docker images to run. In this case, it will be MySQL server and WordPress image.
      db:
        image: mysql:5.7
        # image: mysql:5.7 indicates the MySQL database container image from Docker Hub used in this installation.
        restart: always
        environment:
          MYSQL_ROOT_PASSWORD: MyR00tMySQLPa$$5w0rD
          MYSQL_DATABASE: MyWordPressDatabaseName
          MYSQL_USER: MyWordPressUser
          MYSQL_PASSWORD: Pa$$5w0rD
          # Previous four lines define the main variables needed for the MySQL container to work: database, database username, database user password, and the MySQL root password.
      wordpress:
        depends_on:
          - db
        image: wordpress:latest
        restart: always
        # Restart line controls the restart mode, meaning if the container stops running for any reason, it will restart the process immediately.
        ports:
          - "8000:80"
          # The previous line defines the port that the WordPress container will use. After successful installation, the full path will look like this: http://localhost:8000
        environment:
          WORDPRESS_DB_HOST: db:3306
          WORDPRESS_DB_USER: MyWordPressUser
          WORDPRESS_DB_PASSWORD: Pa$$5w0rD
          WORDPRESS_DB_NAME: MyWordPressDatabaseName
    # Similar to MySQL image variables, the last four lines define the main variables needed for the WordPress container to work properly with the MySQL container.
        volumes:
          ["./:/var/www/html"]
    volumes:
      mysql: {}
    EOT

    docker-compose up -d

    EOF

  network {
    port = openstack_networking_port_v2.port_1.id
  }
}



