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

JenkinsUserSSHKey () {
    sudo adduser --disabled-password --gecos "" $1 --shell /bin/bash
    sudo mkdir /home/$1/$1_slave /home/$1/.ssh
    sudo cp /vagrant/gitlab.pub /home/$1/.ssh/authorized_keys
    sudo chown -R $1:$1 /home/$1/$1_slave
}

awsinstall () {
    apt-get install -y python-pip maven awscli
    pip install --upgrade pip
    pip install awscli --upgrade --user
    echo 'export PATH=~/.local/bin:$PATH' >> ~/.bashrc
    source ~/.bashrc
}
 
dockerinstall () {
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get update && apt-get install -y docker-ce
    usermod -aG docker ubuntu
    usermod -aG docker jenkins
}
# Username 'jslave' and password will be created in the master server and '192.168.106.100' is the IP address of the Jenkins Master server.
swarm_slave_connector (){
    curl https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/3.8/swarm-client-3.8.jar -o /root/swarm-client.jar
    sed -i '/^exit 0/ijava -jar /root/swarm-client.jar -username jslave -password freebsd -autoDiscoveryAddress 192.168.106.100 &' /etc/rc.local
    add-apt-repository -y ppa:webupd8team/java && apt-get update
    echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
    echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
    apt-get install oracle-java8-installer -y
}
 
if [ "$relver" = "rhel6" -o "$relver" = "rhel7" ]
then
    yum upgrade -y
elif [ "$relver" = "Ubuntu" ]
then
    JenkinsUserSSHKey jenkins
    swarm_slave_connector
    awsinstall
    dockerinstall
else
    echo "Script is not determined the type of Operation System!!!" | tee -a ${LOG}
fi
