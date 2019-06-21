#!/usr/bin/env bash
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address $1 > $2/cluster-output.txt
mkdir -p $2/.kube
cp -i /etc/kubernetes/admin.conf $2/.kube/config
chown $3:$3 $2/.kube/config
source <(kubectl completion bash) 
echo "source <(kubectl completion bash)" >> $2/.bashrc
runuser -l vagrant -c 'kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml'

token=$(cat $2/cluster-output.txt | tail -n2 | head -1 | awk '{ print $5 }')
hash=$(cat $2/cluster-output.txt | tail -n1 | awk '{ print $(NF)}')

echo "sudo kubeadm join $1:6443 --token $token --discovery-token-ca-cert-hash $hash" > /vagrant/scripts/jointocluster.sh
chmod +x /vagrant/scripts/jointocluster.sh
