#!/usr/bin/env bash

yum -y install epel-release && yum install -y net-tools telnet bind-utils vim jq wget curl conntrack-tools tcpdump socat ntp kmod ceph-common dos2unix bash-completion

echo 'Prepare hosts file to resolve Host names'
cat > /etc/hosts <<EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
172.18.8.10  kubemaster
172.18.8.101 kubenode1
172.18.8.102 kubenode2
172.18.8.103 kubenode3
EOF

# Enable NTP and disable SeLinux
echo '******** Sync Time ********'
systemctl start ntpd
systemctl enable ntpd
echo '******** Disable SeLinux ********'
setenforce 0
sed -i 's/=enforcing/=disabled/g' /etc/selinux/config

# Disable SWAP
echo '******** Disable SWAP ********'
swapoff -a
sed -i '/swap/s/^/#/' /etc/fstab

# Install Docker
yum -y install docker && systemctl enable docker && systemctl start docker

# Configure Kubernetes Repository and Install Kubernetes Components
echo '******** Install Kubernetes Components ********'
cat << EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
yum install -y kubelet kubeadm kubectl && systemctl enable kubelet && systemctl start kubelet


# Configure SysCtl
cat << EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward=1
EOF
sysctl --system

