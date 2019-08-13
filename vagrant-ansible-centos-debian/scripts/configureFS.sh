#!/usr/bin/env bash

if [ $# -lt 7 ]
then
    echo "Usage: $0 virtualIP dbUser dbPass dbName defaultPass domainName pgSQLIP"
    exit 110
fi

subnet=$(echo $1 | awk 'BEGIN{FS=".";OFS=".";} {print $1,$2,$3;}')
declare -A configFiles=([modules.conf.xml]=autoload_configs/modules.conf.xml [switch.conf.xml]=autoload_configs/switch.conf.xml [vars.xml]=vars.xml [internal.xml]=sip_profiles/internal.xml [external.xml]=sip_profiles/external.xml [acl.conf.xml]=autoload_configs/acl.conf.xml [verto.conf.xml]=autoload_configs/verto.conf.xml [fifo.conf.xml]=autoload_configs/fifo.conf.xml [db.conf.xml]=autoload_configs/db.conf.xml [callcenter.conf.xml]=autoload_configs/callcenter.conf.xml [voicemail.conf.xml]=autoload_configs/voicemail.conf.xml)
declare -A ARRAY=([pgip]=$7 [dbUser]=$2 [dbPass]=$3 [dbName]=$4)
declare -A varsArray=([havip]=$1 [defaultPass]=$5 [domainName]=$6)
declare -A varsToRemove=([sip_profiles]='external-ipv6 internal-ipv6.xml external-ipv6.xml' [dialplan]='public public.xml default default.xml features.xml skinny-patterns.xml skinny-patterns' [directory]='*')
declare -A dirplanVars=([directory]=directoryDomain.xml [dialplan]=dialplanDomain.xml)

mkdir /etc/freeswitch/sip_profiles/internal && chown -R freeswitch:freeswitch /etc/freeswitch/sip_profiles/internal
for folder in "${!varsToRemove[@]}"
do
     cd /etc/freeswitch/$folder/ && rm -rf ${varsToRemove[$folder]}
done

for dirplan in "${!dirplanVars[@]}"
do
    mkdir /etc/freeswitch/$dirplan/$6/
    cp /vagrant/scripts/fstemps/${dirplanVars[$dirplan]} /etc/freeswitch/$dirplan/$6.xml
    chown -R freeswitch:freeswitch /etc/freeswitch/$dirplan/
done

echo "$1   $6" >> /etc/hosts
for file in "${!configFiles[@]}"
do
    cp /vagrant/scripts/fstemps/$file /etc/freeswitch/${configFiles[$file]}
done

sed -i "s/fsSubnet/$subnet/g" /etc/freeswitch/autoload_configs/acl.conf.xml

for key in "${!ARRAY[@]}"
do
    sed -i "s/$key/${ARRAY[$key]}/g" /etc/freeswitch/sip_profiles/internal.xml
    sed -i "s/$key/${ARRAY[$key]}/g" /etc/freeswitch/sip_profiles/external.xml
    sed -i "s/$key/${ARRAY[$key]}/g" /etc/freeswitch/autoload_configs/switch.conf.xml
    sed -i "s/$key/${ARRAY[$key]}/g" /etc/freeswitch/autoload_configs/db.conf.xml
    sed -i "s/$key/${ARRAY[$key]}/g" /etc/freeswitch/autoload_configs/callcenter.conf.xml
    sed -i "s/$key/${ARRAY[$key]}/g" /etc/freeswitch/autoload_configs/fifo.conf.xml
    sed -i "s/$key/${ARRAY[$key]}/g" /etc/freeswitch/autoload_configs/voicemail.conf.xml
done


for var in "${!varsArray[@]}"
do
    sed -i "s/$var/${varsArray[$var]}/g" /etc/freeswitch/vars.xml
done

cp /home/vagrant/{agent.pem,cafile.pem,wss.pem} /etc/freeswitch/tls/
rm -rf /var/lib/freeswitch/db/*
chown -R freeswitch:freeswitch /etc/init.d/fsrecover /etc/freeswitch/tls/
systemctl restart freeswitch && systemctl enable freeswitch
