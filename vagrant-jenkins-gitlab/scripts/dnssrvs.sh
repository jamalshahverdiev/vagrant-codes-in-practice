#!/usr/bin/env bash

yum install -y bind bind-utils

yes | cp -rf /vagrant/scripts/named.conf /etc/named.conf
sed -i "s/changeme/$1/g" /etc/named.conf

if [ "$(hostname)" = "dns1" ]
then
cat <<EOF >> /etc/named.conf 
zone "smbapp.loc" IN {
        type master;
        file "/var/named/forward.smbapp.loc";
        allow-update { none; };
};
EOF
cp /vagrant/scripts/forward.smbapp.loc /var/named/forward.smbapp.loc
systemctl enable named && systemctl restart named
fi

if [ "$(hostname)" = "dns2" ]
then
cat <<EOF >> /etc/named.conf
zone "smbapp.loc" IN {
        type slave;
        file "slaves/forward.smbapp.loc";
        masters { 10.1.42.161; };
};
EOF
systemctl enable named && systemctl restart named
fi


