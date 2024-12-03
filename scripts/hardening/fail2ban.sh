#!/bin/bash

apt install -y fail2ban

systemctl is-active fail2ban | grep -q ^active || systemctl restart fail2ban
systemctl enable fail2ban
