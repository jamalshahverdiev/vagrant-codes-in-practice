#!/usr/bin/env bash

yum install -y http://files.freeswitch.org/freeswitch-release-1-6.noarch.rpm 
yum install -y freeswitch-config-vanilla freeswitch-lang-* freeswitch-sounds-*
systemctl enable freeswitch && systemctl start freeswitch
echo "FreeSWITCH server installed and configured"
#fs_cli -rRS
