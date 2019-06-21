#### Update the system packages
apt-get update
apt-get install -y apt-transport-https
apt-get upgrade -y

#### Install Virtualbox
echo virtualbox-ext-pack virtualbox-ext-pack/license select true | sudo debconf-set-selections
apt install -y virtualbox virtualbox-ext-pack

#### Install Mikikube
wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube-linux-amd64
sudo mv minikube-linux-amd64 /usr/local/bin/minikube

#### Install Kubectl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt update
apt -y install kubectl
#kubectl version -o json

#### Install Docker and start Minikube
apt install -y docker.io
minikube start --vm-driver=none

