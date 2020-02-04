#!/usr/bin/env bash

yum -y install centos-release-gluster6
yum makecache
yum -y install glusterfs-server
systemctl enable --now glusterd.service

for i in dm_snapshot dm_mirror dm_thin_pool; do modprobe $i; done
#lsmod |  egrep 'dm_snapshot|dm_mirror|dm_thin_pool'

if [ $HOSTNAME = prodgluster03 ]
then
    gluster peer probe prodgluster01
    gluster peer probe prodgluster02
    gluster peer status
fi
