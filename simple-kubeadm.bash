#!/bin/bash

# Download the tooling needed to add software repos and download things.
apt-get install curl apt-transport-https gnupg-agent ca-certificates software-properties-common -y


echo "deb https://download.docker.com/linux/ubuntu xenial stable" >> /etc/apt/sources.list.d/docker.list
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" >> /etc/apt/sources.list.d/kubernetes.list
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - 
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - 
apt-get update; apt-get install -y ethtool socat ebtables conntrack libnetfilter-conntrack3 docker-ce=18.06.1~ce~3-0~ubuntu kubelet=1.14.1-00 kubeadm=1.14.1-00 kubectl=1.14.1-00 kubernetes-cni cri-tools
systemctl enable kubelet.service

kubeadm init  --pod-network-cidr=10.98.0.0/16 

curl -X GET https://localhost:6443/apis/apiextensions.k8s.io/v1 --header "Authorization: Bearer $TOKEN" --insecure |less

