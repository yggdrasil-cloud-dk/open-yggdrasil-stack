#!/bin/bash

set -xe


#iptables -t mangle -A PREROUTING -m conntrack --ctstate INVALID -j DROP
#iptables -t mangle -A PREROUTING -p tcp ! --syn -m conntrack --ctstate NEW -j DROP
#iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP # Drop NULL packets
#iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP # Drop XMAS packets

cd workspace

cat > ./nginx.conf <<'EOF'
user nginx nginx;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


load_module modules/ngx_http_modsecurity_module.so;

events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;
    server_names_hash_max_size 6144;
    server_names_hash_bucket_size 128;

modsecurity on;
modsecurity_rules_file /etc/nginx/modsec/modsec_includes.conf;

   # server {
   #     listen       80;
   #     server_name  localhost;

   #     #include /etc/nginx/modsec/modsec_on.conf;

   #     #charset koi8-r;

   #     #access_log  logs/host.access.log  main;

   #     location / {
   #         root   html;
   #         index  index.html index.htm;
   #         #include /etc/nginx/modsec/modsec_rules.conf;
   #     }

   #     include /etc/nginx/insert.d/*.conf;

   #     #error_page  404              /404.html;

   #     # redirect server error pages to the static page /50x.html
   #     #
   #     error_page   500 502 503 504  /50x.html;
   #     location = /50x.html {
   #         root   html;
   #     }

   #     # proxy the PHP scripts to Apache listening on 127.0.0.1:80
   #     #
   #     #location ~ \.php$ {
   #     #    proxy_pass   http://127.0.0.1;
   #     #}

   #     # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
   #     #
   #     #location ~ \.php$ {
   #     #    root           html;
   #     #    fastcgi_pass   127.0.0.1:9000;
   #     #    fastcgi_index  index.php;
   #     #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
   #     #    include        fastcgi_params;
   #     #}

   #     # deny access to .htaccess files, if Apache's document root
   #     # concurs with nginx's one
   #     #
   #     #location ~ /\.ht {
   #     #    deny  all;
   #     #}
   # }


include /etc/nginx/conf.d/*.conf;
    # another virtual host using mix of IP-, name-, and port-based configuration
    #
    #server {
    #    listen       8000;
    #    listen       somename:8080;
    #    server_name  somename  alias  another.alias;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}


    # HTTPS server
    
    server {
        listen       443 ssl;
        server_name  console.yggdrasilcloud.dk;

        ssl_certificate      /etc/letsencrypt/live/console.yggdrasilcloud.dk/fullchain.pem;
        ssl_certificate_key  /etc/letsencrypt/live/console.yggdrasilcloud.dk/privkey.pem;

        ssl_session_cache    shared:SSL:1m;
        ssl_session_timeout  5m;

        ssl_ciphers  HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers  on;

        #location / {
        #    root   html;
        #    index  index.html index.htm;
        #}

	location / {
            proxy_pass http://10.0.10.100:9997/;
            proxy_redirect http://10.0.10.100:9997/ /;
            proxy_buffering off;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $host;
            proxy_set_header Host $http_host;
        }
    }

}
EOF

# ports 443 and 80
docker run -d --name nginx-modsecurity \
  --restart=always \
  --net=host \
  -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro \
  -v /data/nginx/conf.d:/etc/nginx/conf.d:rw \
  -v /etc/letsencrypt:/etc/letsencrypt:ro \
  really/nginx-modsecurity




