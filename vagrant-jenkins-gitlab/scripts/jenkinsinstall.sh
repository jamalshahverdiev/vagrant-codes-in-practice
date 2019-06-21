#!/usr/bin/env bash

curl --silent --location http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo | sudo tee /etc/yum.repos.d/jenkins.repo

rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
yum install -y jenkins
systemctl start jenkins && systemctl enable jenkins

while [ ! -f /var/lib/jenkins/secrets/initialAdminPassword ]
do
  sleep 2
done

echo "Jenkins Admin Password: $(cat /var/lib/jenkins/secrets/initialAdminPassword)"
