terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

variable "prep_cmds" {
 type        = string
 default     = <<-EOT
  IP=$IP  
  (
  ssh-keygen -f "/root/.ssh/known_hosts" -R "$IP"
  while ! timeout 3s ssh -o StrictHostKeyChecking=no ubuntu@$IP echo hi; do sleep 5; done
  ssh -o StrictHostKeyChecking=no ubuntu@$IP sudo bash -s <<EOF
  rm -rf /root/.ssh
  cp -r /home/ubuntu/.ssh/ /root/
  EOF
  ssh-keygen -f "/root/.ssh/known_hosts" -R "$IP"
  ) 1>/dev/null 2>&1

  
  cat >> ~/.ssh/config <<EOF

  Host $HOSTNAME
    Hostname $IP
    User root
  EOF
  EOT
}


resource "libvirt_network" "net_main" {
  name = "openstack-vlans"
  addresses = ["192.168.121.0/24"]
  dhcp {
    enabled = true
  }
  provisioner "local-exec" {
    command = "> ~/.ssh/config"
    interpreter = ["bash", "-c"]
  }

}

resource "libvirt_network" "net_prov" {
  name = "provider"
  addresses = ["10.0.80.0/24"]
  dhcp {
    enabled = true
  }
}
