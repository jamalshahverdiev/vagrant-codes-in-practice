#!/usr/bin/env bash
sleep 30
branchName="master"
buildNumber="3"
sed -i.bak "s/newAdmin/$1/g" /vagrant/scripts/temps/user.xml
sed -i.bak "s/serverIP/$2/g" /vagrant/scripts/temps/user.xml
sed -i.bak "s/appRepo/$3/g" /vagrant/scripts/temps/hostedrepo.json
curl -i -H "Accept: application/xml" -H "Content-Type: application/xml; charset=UTF-8"  -v -d "@/vagrant/scripts/temps/user.xml" -u admin:admin123 http://$2:8081/service/local/users
curl -H "Content-Type: application/json" -X POST -v -trace-ascii -d "@/vagrant/scripts/temps/hostedrepo.json" -u admin:admin123 http://$2:8081/service/local/repositories

# Upload Artifact to the Repository
curl -v -u $1:$1123 --upload-file /home/vagrant/newapp/target/newapp-1.0-SNAPSHOT.jar "http://$2:8081/content/sites/$31/$branchName/$buildNumber/newapp-1.0-SNAPSHOT.jar"

# To download this artifact just uncomment the following line
#curl -v -u $1:$1'123' -XGET "http://$2:8081/content/sites/$31/$branchName/$buildNumber/newapp-1.0-SNAPSHOT.jar" -o newapp-1.0-SNAPSHOT.jar
