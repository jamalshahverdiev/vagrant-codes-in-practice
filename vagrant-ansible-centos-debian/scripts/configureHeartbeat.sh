#!/usr/bin/env bash

if [ $# -lt 1 ]
then
    echo "Usage: $0 fsHostName"
    exit 102
fi

apt install -y heartbeat

cp /vagrant/scripts/fsrecover /etc/init.d/
chmod 777 /etc/init.d/fsrecover

cat <<'EOF' > /etc/ha.d/authkeys
auth 1
1 sha1 $4$/IfEMITn$esmkF2W54ywbcBU/t1zBUr1wQcU$
EOF

chmod 600 /etc/ha.d/authkeys

cat <<EOF > /etc/ha.d/ha.cf
logfacility local0
debug 3
debugfile /var/log/ha-debug
keepalive 100ms
deadtime 2
warntime 1
initdead 120
udpport 694
bcast eth1
#ucast eth1 10.3.56.11
#ucast eth1 10.3.56.12
node fssrv1 fssrv2
auto_failback off
#autojoin none
EOF

cat <<EOF > /etc/ha.d/haresources
$1 IPaddr2::10.3.56.100/24/eth1 fsrecover::fsrecover
EOF

systemctl restart heartbeat && systemctl enable heartbeat
