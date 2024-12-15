############
# Server 1 #
############

resource "openstack_compute_instance_v2" "db_1" {
  name            = "db_1"
  image_name        = "jammy-server-cloudimg-amd64"
  security_groups = ["db"]
  flavor_name       = "m1.medium"
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
      # Services line define which Docker images to run. In this case, it will be MySQL server and WordPress image.
      db:
        image: mysql:5.7
        # image: mysql:5.7 indicates the MySQL database container image from Docker Hub used in this installation.
        restart: always
        ports:
          - "3306:3306"
        environment:
          MYSQL_ROOT_PASSWORD: MyRootPass
          MYSQL_DATABASE: MyWordPressDatabaseName
          MYSQL_USER: MyWordPressUser
          MYSQL_PASSWORD: MyUserPass
          # Previous four lines define the main variables needed for the MySQL container to work: database, database username, database user password, and the MySQL root password.
      
    volumes:
      mysql: {}
    EOT

    docker-compose up -d

    #docker exec -it -u root default_db_1 bash -c "mysqldump --protocol=socket -u root -pMyR00tMySQLPa12295w0rD  MyWordPressDatabaseName > MyWordPressDatabaseName.sql" && docker cp default_db_1:MyWordPressDatabaseName.sql .
    #docker cp MyWordPressDatabaseName.sql default_db_1:. && docker exec -it -u root default_db_1 bash -c "mysqldump --protocol=socket -u root -pMyR00tMySQLPa12295w0rD  MyWordPressDatabaseName < MyWordPressDatabaseName.sql"

    EOF

  network {
    uuid = openstack_networking_network_v2.network_2.id
  }
}

############
# Server 2 #
############

resource "openstack_compute_instance_v2" "db_2" {
  name            = "db_2"
  image_name        = "jammy-server-cloudimg-amd64"
  security_groups = ["db"]
  flavor_name       = "m1.medium"
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
      # Services line define which Docker images to run. In this case, it will be MySQL server and WordPress image.
      db:
        image: mysql:5.7
        # image: mysql:5.7 indicates the MySQL database container image from Docker Hub used in this installation.
        restart: always
        ports:
          - "3306:3306"
        environment:
          MYSQL_ROOT_PASSWORD: MyRootPass
          MYSQL_DATABASE: MyWordPressDatabaseName
          MYSQL_USER: MyWordPressUser
          MYSQL_PASSWORD: MyUserPass
          # Previous four lines define the main variables needed for the MySQL container to work: database, database username, database user password, and the MySQL root password.

    volumes:
      mysql: {}
    EOT

    docker-compose up -d

    #docker exec -it -u root default_db_1 bash -c "mysqldump --protocol=socket -u root -pMyR00tMySQLPa12295w0rD  MyWordPressDatabaseName > MyWordPressDatabaseName.sql" && docker cp default_db_1:MyWordPressDatabaseName.sql .
    #docker cp MyWordPressDatabaseName.sql default_db_1:. && docker exec -it -u root default_db_1 bash -c "mysqldump --protocol=socket -u root -pMyR00tMySQLPa12295w0rD  MyWordPressDatabaseName < MyWordPressDatabaseName.sql"

    EOF

  network {
    uuid = openstack_networking_network_v2.network_2.id
  }
}

############
# Server 3 #
############

resource "openstack_compute_instance_v2" "db_3" {
  name            = "db_3"
  image_name        = "jammy-server-cloudimg-amd64"
  security_groups = ["db"]
  flavor_name       = "m1.medium"
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
      # Services line define which Docker images to run. In this case, it will be MySQL server and WordPress image.
      db:
        image: mysql:5.7
        # image: mysql:5.7 indicates the MySQL database container image from Docker Hub used in this installation.
        restart: always
        ports:
          - "3306:3306"
        environment:
          MYSQL_ROOT_PASSWORD: MyRootPass
          MYSQL_DATABASE: MyWordPressDatabaseName
          MYSQL_USER: MyWordPressUser
          MYSQL_PASSWORD: MyUserPass
          # Previous four lines define the main variables needed for the MySQL container to work: database, database username, database user password, and the MySQL root password.
    volumes:
      mysql: {}
    EOT

    docker-compose up -d

    #docker exec -it -u root default_db_1 bash -c "mysqldump --protocol=socket -u root -pMyR00tMySQLPa12295w0rD  MyWordPressDatabaseName > MyWordPressDatabaseName.sql" && docker cp default_db_1:MyWordPressDatabaseName.sql .
    #docker cp MyWordPressDatabaseName.sql default_db_1:. && docker exec -it -u root default_db_1 bash -c "mysqldump --protocol=socket -u root -pMyR00tMySQLPa12295w0rD  MyWordPressDatabaseName < MyWordPressDatabaseName.sql"

    EOF

  network {
    uuid = openstack_networking_network_v2.network_2.id
  }
}
