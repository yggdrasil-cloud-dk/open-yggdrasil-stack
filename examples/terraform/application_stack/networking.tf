
############
# Networks #
############

resource "openstack_networking_network_v2" "network_1" {
  name           = "app_net"
  admin_state_up = "true"
}

resource "openstack_networking_network_v2" "network_2" {
  name           = "db_net"
  admin_state_up = "true"
}

###########
# Subnets #
###########

resource "openstack_networking_subnet_v2" "subnet_1" {
  network_id = openstack_networking_network_v2.network_1.id
  cidr       = "172.16.201.0/24"
  dns_nameservers = ["8.8.8.8"]
  ip_version = 4
}

resource "openstack_networking_subnet_v2" "subnet_2" {
  network_id = openstack_networking_network_v2.network_2.id
  cidr       = "172.16.10.0/24"
  dns_nameservers = ["8.8.8.8"]
  ip_version = 4
}


##########
# Router #
##########


resource "openstack_networking_router_v2" "router_1" {
  name                = "my_router"
  admin_state_up      = true
  external_network_id = "461d0394-654a-42be-bd01-523838b38f51"
}


resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = openstack_networking_router_v2.router_1.id
  subnet_id = openstack_networking_subnet_v2.subnet_1.id
}

resource "openstack_networking_router_interface_v2" "router_interface_2" {
  router_id = openstack_networking_router_v2.router_1.id
  subnet_id = openstack_networking_subnet_v2.subnet_2.id
}


##############
# Sec Groups #
##############

# app #

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


# db #

resource "openstack_networking_secgroup_v2" "secgroup_2" {
  name        = "db"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_db_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup_2.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_db_2" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 3306
  port_range_max    = 3306
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup_2.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_db_3" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1186
  port_range_max    = 1186
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup_2.id
}



#########
# ports #
#########

# app port 1

resource "openstack_networking_port_v2" "port_1" {
  network_id = openstack_networking_network_v2.network_1.id
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet_1.id
    ip_address = "172.16.201.11"
  }
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


# app port 2

resource "openstack_networking_port_v2" "port_2" {
  network_id = openstack_networking_network_v2.network_1.id
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet_1.id
    ip_address = "172.16.201.12"
  }
}

resource "openstack_networking_port_secgroup_associate_v2" "port_2" {
  port_id = openstack_networking_port_v2.port_2.id
  security_group_ids = [
    openstack_networking_secgroup_v2.secgroup_1.id
  ]
}

resource "openstack_networking_floatingip_v2" "floatip_2" {
  pool = "public1"
}

resource "openstack_networking_floatingip_associate_v2" "fip_2" {
  floating_ip = openstack_networking_floatingip_v2.floatip_2.address
  port_id     = openstack_networking_port_v2.port_2.id
}

# app port 3

resource "openstack_networking_port_v2" "port_3" {
  network_id = openstack_networking_network_v2.network_1.id
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet_1.id
    ip_address = "172.16.201.13"
  }
}

resource "openstack_networking_port_secgroup_associate_v2" "port_3" {
  port_id = openstack_networking_port_v2.port_3.id
  security_group_ids = [
    openstack_networking_secgroup_v2.secgroup_1.id
  ]
}

resource "openstack_networking_floatingip_v2" "floatip_3" {
  pool = "public1"
}

resource "openstack_networking_floatingip_associate_v2" "fip_3" {
  floating_ip = openstack_networking_floatingip_v2.floatip_3.address
  port_id     = openstack_networking_port_v2.port_3.id
}

#################
# Load balancer #
#################

resource "openstack_lb_loadbalancer_v2" "lb_1" {
  vip_network_id = openstack_networking_network_v2.network_1.id
}

resource "openstack_networking_floatingip_v2" "floatip_4" {
  pool = "public1"
}

resource "openstack_networking_floatingip_associate_v2" "floatip_4" {
  floating_ip = openstack_networking_floatingip_v2.floatip_4.address
  port_id     = openstack_lb_loadbalancer_v2.lb_1.vip_port_id
}

resource "openstack_lb_listener_v2" "listener_1" {
  protocol        = "HTTP"
  protocol_port   = 80
  loadbalancer_id = openstack_lb_loadbalancer_v2.lb_1.id
}

resource "openstack_lb_pool_v2" "pool_1" {
  protocol    = "HTTP"
  lb_method   = "ROUND_ROBIN"
  listener_id = openstack_lb_listener_v2.listener_1.id
}

resource "openstack_lb_members_v2" "members_1" {
  pool_id = openstack_lb_pool_v2.pool_1.id

  member {
    address       = "172.16.201.11"
    protocol_port = 80
  }

  member {
    address       = "172.16.201.12"
    protocol_port = 80
  }

  member {
    address       = "172.16.201.13"
    protocol_port = 80
  }
}