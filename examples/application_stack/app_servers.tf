############
# Server 1 #
############

resource "openstack_compute_instance_v2" "instance_1" {
  name            = "app_1"
  image_name        = "jammy-server-cloudimg-amd64"
  flavor_name       = "m1.small"
  key_pair        = "testkey"
  user_data       = <<-EOF
    #!/bin/bash
    
    set -x
    
    echo ubuntu:ubuntu | chpasswd

    sudo apt update && \
    DEBIAN_FRONTEND=noninteractive sudo apt install -y docker.io docker-compose

    cat > docker-compose.yml <<EOT
    version: "3" 
    services:
      wordpress:
        image: wordpress:latest
        restart: always
        network_mode: "host"  
        environment:
          WORDPRESS_DB_HOST: ${openstack_compute_instance_v2.db_1.access_ip_v4}:3306
          WORDPRESS_DB_USER: MyWordPressUser
          WORDPRESS_DB_PASSWORD: MyUserPass
          WORDPRESS_DB_NAME: MyWordPressDatabaseName
        volumes:
          ["./:/var/www/html"]
    EOT

    docker-compose up -d

    #docker exec -it -u root default_db_1 bash -c "mysqldump --protocol=socket -u root -pMyR00tMySQLPa12295w0rD  MyWordPressDatabaseName > MyWordPressDatabaseName.sql" && docker cp default_db_1:MyWordPressDatabaseName.sql .
    #docker cp MyWordPressDatabaseName.sql default_db_1:. && docker exec -it -u root default_db_1 bash -c "mysqldump --protocol=socket -u root -pMyR00tMySQLPa12295w0rD  MyWordPressDatabaseName < MyWordPressDatabaseName.sql"

    EOF

  network {
    port = openstack_networking_port_v2.port_1.id
  }
}

############
# Server 2 #
############

resource "openstack_compute_instance_v2" "instance_2" {
  name            = "app_2"
  image_name        = "jammy-server-cloudimg-amd64"
  flavor_name       = "m1.small"
  key_pair        = "testkey"
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
      wordpress:
        image: wordpress:latest
        restart: always
        network_mode: "host"
        environment:
          WORDPRESS_DB_HOST: ${openstack_compute_instance_v2.db_1.access_ip_v4}:3306
          WORDPRESS_DB_USER: MyWordPressUser
          WORDPRESS_DB_PASSWORD: MyUserPass
          WORDPRESS_DB_NAME: MyWordPressDatabaseName
        volumes:
          ["./:/var/www/html"]
    EOT

    docker-compose up -d

    #docker exec -it -u root default_db_1 bash -c "mysqldump --protocol=socket -u root -pMyR00tMySQLPa12295w0rD  MyWordPressDatabaseName > MyWordPressDatabaseName.sql" && docker cp default_db_1:MyWordPressDatabaseName.sql .
    #docker cp MyWordPressDatabaseName.sql default_db_1:. && docker exec -it -u root default_db_1 bash -c "mysqldump --protocol=socket -u root -pMyR00tMySQLPa12295w0rD  MyWordPressDatabaseName < MyWordPressDatabaseName.sql"

    EOF

  network {
    port = openstack_networking_port_v2.port_2.id
  }
}

############
# Server 3 #
############

resource "openstack_compute_instance_v2" "instance_3" {
  name            = "app_3"
  image_name        = "jammy-server-cloudimg-amd64"
  flavor_name       = "m1.small"
  key_pair        = "testkey"
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
      wordpress:
        image: wordpress:latest
        restart: always
        network_mode: "host"
        environment:
          WORDPRESS_DB_HOST: ${openstack_compute_instance_v2.db_1.access_ip_v4}:3306
          WORDPRESS_DB_USER: MyWordPressUser
          WORDPRESS_DB_PASSWORD: MyUserPass
          WORDPRESS_DB_NAME: MyWordPressDatabaseName
        volumes:
          ["./:/var/www/html"]
    EOT

    docker-compose up -d

    #docker exec -it -u root default_db_1 bash -c "mysqldump --protocol=socket -u root -pMyR00tMySQLPa12295w0rD  MyWordPressDatabaseName > MyWordPressDatabaseName.sql" && docker cp default_db_1:MyWordPressDatabaseName.sql .
    #docker cp MyWordPressDatabaseName.sql default_db_1:. && docker exec -it -u root default_db_1 bash -c "mysqldump --protocol=socket -u root -pMyR00tMySQLPa12295w0rD  MyWordPressDatabaseName < MyWordPressDatabaseName.sql"

    EOF

  network {
    port = openstack_networking_port_v2.port_3.id
  }
}
