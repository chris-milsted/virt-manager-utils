#!/bin/sh



virsh net-define ./network-a.xml

virsh net-define ./network-b.xml

virt-install \
--name fedora.kube.com \
--description "Kubeadm test machine" \
--os-type=Linux \
--os-variant=fedora34 \
--ram=8196 \
--vcpus=4 \
--disk path=/var/lib/libvirt/images/fedora.kube.com.img,bus=virtio,size=30 \
--graphics none \
--noautoconsole \
--console pty,target_type=serial \
--extra-args="inst.ks=file:/anaconda-ks.cfg console=ttyS0,115200n8 serial" \
--initrd-inject="/home/chris/Documents/Git/virt-manager-utils/anaconda-ks.cfg" \
--location '/home/chris/Downloads/Fedora-Server-dvd-x86_64-34-1.2.iso' \
--network network:networka \
--network network:networkb \
--network network:default 

virsh net-start networka

virsh net-start networkb

virsh start fedora.kube.com

virsh console fedora.kube.com

#####

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

#####

sudo dnf install docker
sudo dnf install containerd

#####

cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

# Set SELinux in permissive mode (effectively disabling it)
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

sudo systemctl enable --now kubelet

######

sudo systemctl stop swap-create@zram0
sudo touch /etc/systemd/zram-generator.conf
reboot

#####

sudo ip route add 0.0.0.0 via 10.10.100.145 dev enp2s0 metric 105
sudo ip route add 0.0.0.0 via 172.16.100.201 dev enp1s0 metric 106

kubeadm init