#!/usr/bin/env bash
checkver () {
    if [ -f "/etc/redhat-release" ]
    then
        version=$(cat /etc/redhat-release | awk '{ print $(NF-1)}' | cut -f1 -d'.')
 
        if [ "$version" = "6" ]
        then
            echo "Red Hat version is $version" | tee -a ${LOG}
            relver="rhel$version"
        elif [ "$version" = "7" ]
        then
            echo "Red Hat version is $version" | tee -a ${LOG}
            relver="rhel$version"
        fi
    elif [ -f "/etc/issue" ]
    then
        echo "Ubuntu operation system"
        relver=$(cat /etc/issue | awk '{ print $1 }')
    else
        version="unknown"
        echo "The os type and version is not determined!!!" | tee -a ${LOG}
    fi
}
 
checkver
 
if [ "$relver" = "rhel6" -o "$relver" = "rhel7" ]
then
    yum upgrade -y
elif [ "$relver" = "Ubuntu" ]
then
    DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get dist-upgrade -y
    ls -la ~/ > /root/homelist.txt
else
    echo "Script is not determined the type of Operation System!!!" | tee -a ${LOG}
fi
