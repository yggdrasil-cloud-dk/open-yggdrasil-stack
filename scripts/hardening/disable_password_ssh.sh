#!/bin/bash

find /etc/ssh/sshd_config* -type f | xargs sed -i 's/.*PasswordAuthentication yes/PasswordAuthentication no/g'
rm -f /etc/ssh/sshd_config.d/50-cloud-init.conf
systemctl restart ssh
