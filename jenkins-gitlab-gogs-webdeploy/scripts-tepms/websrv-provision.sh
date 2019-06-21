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
 
dockerinstall () {
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get update && apt-get install -y docker-ce
    usermod -aG docker ubuntu
}
 
if [ "$relver" = "rhel6" -o "$relver" = "rhel7" ]
then
    yum upgrade -y
elif [ "$relver" = "Ubuntu" ]
then
    dockerinstall
else
    echo "Script is not determined the type of Operation System!!!" | tee -a ${LOG}
fi
