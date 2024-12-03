
mkdir -p /root/nginx_configs/heat_templates 


cat > /root/nginx_configs/nginx.conf <<EOF

server {                                                                                                                                                 
    listen       80;                                                                                                                                                                                                                                                                                              
    listen  [::]:80;                                                                                                                                                                                                                                                                                              
    server_name  localhost;                                                                                                                                                                                                                                                                                       
                                                                                                                                                                                                                                                                                                                  
    #access_log  /var/log/nginx/host.access.log  main;                                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                                                                                  
    location / {                                                                                                                                                                                                                                                                                                  
        root   /usr/share/nginx/html;                                                                                                                                                                                                                                                                             
        index  index.html index.htm;
        autoindex on;                                                                                                                                                                                                                                                                             
    }                                                                                                                                                                                                                                                                                                             
                                                                                                                                                                                                                                                                                                                  
    #error_page  404              /404.html;                                                                                                                                                                                                                                                                      
                                                                                                                                                                                                                                                                                                                  
    # redirect server error pages to the static page /50x.html                                                                                                                                                                                                                                                    
    #                                                                                                                                                                                                                                                                                                             
    error_page   500 502 503 504  /50x.html;                                                                                                                                                                                                                                                                      
    location = /50x.html {                                                                                                                                                                                                                                                                                        
        root   /usr/share/nginx/html;                                                                                                                                                                                                                                                                             
    }                                                                                                                                                                                                                                                                                                             
                                                                                                                                                         
    # proxy the PHP scripts to Apache listening on 127.0.0.1:80                                                                                          
    #                                                                                                                                                                                                                                                                                                             
    #location ~ \.php$ {                                                                                                                                                                                                                                                                                          
    #    proxy_pass   http://127.0.0.1;                                     
    #}                                                                      
                                                                            
    # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
    #
    #location ~ \.php$ {                   
    #    root           html; 
    #    fastcgi_pass   127.0.0.1:9000;
    #    fastcgi_index  index.php;
    #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
    #    include        fastcgi_params;
    #}

    # deny access to .htaccess files, if Apache's document root
    # concurs with nginx's one
    #
    #location ~ /\.ht {
    #    deny  all;
    #}
}

EOF

cat > /root/nginx_configs/heat_templates/basic_vm_linux.yaml <<EOF
heat_template_version: 2021-04-16

description: Simple template to deploy a single Linux compute instance

parameters:
  network_name:
    type: string
    default: demo-net

resources:
  my_instance:
    type: OS::Nova::Server
    properties:
      image: jammy-server-cloudimg-amd64
      flavor: m1.small
      networks: [{ network: { get_param: network_name } }]
EOF


cat > /root/nginx_configs/heat_templates/basic_vm_windows.yaml <<EOF
heat_template_version: 2021-04-16

description: Simple template to deploy a single Windows compute instance

parameters:
  network_name:
    type: string
    default: demo-net

resources:
  my_instance:
    type: OS::Nova::Server
    properties:
      image: windows_server_2012_r2_standard_eval_kvm_20170321
      flavor: m1.medium
      networks: [{ network: { get_param: network_name } }]
      user_data_format: RAW
      user_data: |
        #ps1
        Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Value 0
EOF


cat > /root/nginx_configs/heat_templates/smb_share.yaml <<EOF
heat_template_version: 2021-04-16

description: Simple template to deploy a 1 GB SMB file share

resources:
  my_instance:
    type: OS::Manila::Share
    properties:
      access_rules: [{ access_to: 0.0.0.0/0, access_type: ip, access_level: rw}]
      is_public: true
      share_network: 1a948868-31c5-4fc6-9434-d93d661b05c9
      share_protocol: CIFS
      share_type: default_share_type
      size: 1
EOF


cat > /root/nginx_configs/heat_templates/mssql.yaml <<EOF
heat_template_version: 2021-04-16

description: Simple template to deploy a single MSSQL instance

parameters:
  network_name:
    type: string
    default: demo-net

resources:
  my_instance:
    type: OS::Nova::Server
    properties:
      image: jammy-server-cloudimg-amd64
      flavor: m1.medium
      networks: [{ network: { get_param: network_name } }]
      user_data_format: RAW
      user_data: |
        #!/bin/bash
        set -x
        apt update
        apt install -y docker.io
        docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=yourStrong(!)Password" -e "MSSQL_PID=Developer" -p 1433:1433 -d mcr.microsoft.com/mssql/server:2022-latest

EOF

cat > /root/nginx_configs/heat_templates/postgres.yaml <<EOF
heat_template_version: 2021-04-16

description: Simple template to deploy a single PostgreSQL instance

parameters:
  network_name:
    type: string
    default: demo-net

resources:
  my_instance:
    type: OS::Nova::Server
    properties:
      image: jammy-server-cloudimg-amd64
      flavor: m1.medium
      networks: [{ network: { get_param: network_name } }]
      user_data_format: RAW
      user_data: |
        #!/bin/bash
        set -x
        apt update
        apt install -y docker.io
        docker run --name some-postgres -e POSTGRES_PASSWORD=mysecretpassword -p 5432:5432 -d postgres
EOF

cat > /root/nginx_configs/heat_templates/nginx.yaml <<EOF
heat_template_version: 2021-04-16

description: Simple template to deploy a single Nginx instance

parameters:
  network_name:
    type: string
    default: demo-net

resources:
  my_instance:
    type: OS::Nova::Server
    properties:
      image: jammy-server-cloudimg-amd64
      flavor: m1.medium
      networks: [{ network: { get_param: network_name } }]
      user_data_format: RAW
      user_data: |
        #!/bin/bash
        set -x
        apt update
        apt install -y docker.io
        docker run --name nginx -p 80:80 -p 443:443 -d nginx
EOF


docker ps | grep nginx || \
docker run -d --name nginx \
  --network host \
  --volume /root/nginx_configs/heat_templates:/usr/share/nginx/html \
  --volume /root/nginx_configs/nginx.conf:/etc/nginx/conf.d/default.conf \
  nginx