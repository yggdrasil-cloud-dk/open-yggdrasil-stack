#!/bin/bash

# wait for internet connectivity
while (! ping -c 3 8.8.8.8); do sleep 5; done


interface=$(ip route | grep "^default" | grep -o 'dev .\+' | cut -d ' ' -f 2)
ip=$(ip -o -f inet addr | grep $interface | awk '{print $4}')
gw=$(ip route | grep "^default" | grep -o 'via .\+' | cut -d ' ' -f 2)
dns=$(resolvectl dns $interface | sed 's/.*: //g')

test -e /opt/revive_internet_access.sh || cat > /opt/revive_internet_access.sh << EOF
#!/bin/bash

while true; do
  if (ip a | grep -q br-ex); then
    if (! ping -c 3 8.8.8.8 > /dev/null 2>&1); then 
      ip addr flush dev $interface
      ip addr add $ip dev br-ex
      ip link set br-ex up
      ip route add default via $gw dev br-ex
      resolvectl dns br-ex $dns
    fi
  fi
  sleep 5
done
EOF

test -e /etc/systemd/system/internet-access-bridge.service || cat > /etc/systemd/system/internet-access-bridge.service << EOF
[Unit]
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=-/bin/bash /opt/revive_internet_access.sh

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable internet-access-bridge
systemctl start internet-access-bridge


