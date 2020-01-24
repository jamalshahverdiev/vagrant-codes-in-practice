#!/usr/bin/env bash

jenkinsIP='10.1.42.120'

plugins='
workflow-aggregator
github
ws-cleanup
greenballs
simple-theme-plugin
kubernetes
docker-workflow
kubernetes-cli
github-branch-source
'

#### Download Jenkins-Cli package
if [ ! -f jenkins-cli.jar ]
then 
    wget http://$jenkinsIP:8080/jnlpJars/jenkins-cli.jar
fi

for plugin in $plugins
do
    java -jar jenkins-cli.jar -s http://$jenkinsIP:8080/ -auth admin:Zumrud123 install-plugin $plugin
done
