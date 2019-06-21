#!/usr/bin/env bash
sudo apt-get update && sudo apt-get dist-upgrade -y
sudo apt-get remove -y docker docker-engine docker.io
sudo apt-get update && sudo apt-get install --allow-unauthenticated -y apt-transport-https ca-certificates curl software-properties-common
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update && sudo apt-get install --allow-unauthenticated -y docker-ce jq
sudo usermod -aG docker vagrant
sudo usermod -aG docker ubuntu
sudo curl -o /usr/local/bin/docker-compose -L "https://github.com/docker/compose/releases/download/1.19.0/docker-compose-$(uname -s)-$(uname -m)"
sudo chmod +x /usr/local/bin/docker-compose
sudo docker-compose -v
