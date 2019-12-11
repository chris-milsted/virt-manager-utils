#!/bin/bash

# virsh  net-list
# virsh  net-edit  $NETWORK_NAME    # Probably "default"

# Find the <dhcp> section, restrict the dynamic range and add host entries for your VMs

# <dhcp>
#   <range start='192.168.122.100' end='192.168.122.254'/>
#   <host mac='52:54:00:6c:3c:01' name='vm1' ip='192.168.122.11'/>
#   <host mac='52:54:00:6c:3c:02' name='vm2' ip='192.168.122.12'/>
#   <host mac='52:54:00:6c:3c:03' name='vm3' ip='192.168.122.12'/>
# </dhcp>

virsh net-update default add ip-dhcp-host \
  "<host mac='52:54:00:00:00:01' name='lb.local.com' ip='192.168.122.10' />" \
  --live --config

virsh net-update default add dns-host \
'<host ip="192.168.122.10">
  <hostname>lb.local.com</hostname>
</host>' \
--live --config

virsh net-update default add ip-dhcp-host \
  "<host mac='52:54:00:00:00:02' name='master-1' ip='192.168.122.11' />" \
  --live --config

virsh net-update default add dns-host \
'<host ip="192.168.122.11">
  <hostname>master-1.local.com</hostname>
</host>' \
--live --config

virsh net-update default add ip-dhcp-host \
  "<host mac='52:54:00:00:00:03' name='master-2' ip='192.168.122.12' />" \
  --live --config

virsh net-update default add dns-host \
'<host ip="192.168.122.12">
  <hostname>master-2.local.com</hostname>
</host>' \
--live --config

virsh net-update default add ip-dhcp-host \
  "<host mac='52:54:00:00:00:04' name='master-3' ip='192.168.122.13' />" \
  --live --config

virsh net-update default add dns-host \
'<host ip="192.168.122.13">
  <hostname>master-3.local.com</hostname>
</host>' \
--live --config

virsh net-update default add ip-dhcp-host \
  "<host mac='52:54:00:00:00:05' name='worker-1' ip='192.168.122.21' />" \
  --live --config

virsh net-update default add dns-host \
'<host ip="192.168.122.21">
  <hostname>worker-1.local.com</hostname>
</host>' \
--live --config

virsh net-update default add ip-dhcp-host \
  "<host mac='52:54:00:00:00:06' name='worker-2' ip='192.168.122.22' />" \
  --live --config

virsh net-update default add dns-host \
'<host ip="192.168.122.22">
  <hostname>worker-2.local.com</hostname>
</host>' \
--live --config

##


virt-install \
--name lb.local.com \
--description "Load Balancer" \
--os-type=Linux \
--os-variant=ubuntu18.04 \
--ram=4096 \
--vcpus=2 \
--disk path=/var/lib/libvirt/images/lb.img,bus=virtio,size=30 \
--graphics none \
--noautoconsole \
--console pty,target_type=serial \
--extra-args="ks=file:/kickstart.ks console=ttyS0,115200n8 serial" \
--initrd-inject="/home/chris/Documents/kubeadm/kickstart.ks" \
--location 'http://gb.archive.ubuntu.com/ubuntu/dists/bionic/main/installer-amd64/' \
--network default,mac='52:54:00:00:00:01'

virt-install \
--name master-1.local.com \
--description "master-1.local.com" \
--os-type=Linux \
--os-variant=ubuntu18.04 \
--ram=4096 \
--vcpus=2 \
--disk path=/var/lib/libvirt/images/master-1.img,bus=virtio,size=30 \
--graphics none \
--noautoconsole \
--console pty,target_type=serial \
--extra-args="ks=file:/kickstart.ks console=ttyS0,115200n8 serial" \
--initrd-inject="/home/chris/Documents/kubeadm/kickstart.ks" \
--location 'http://gb.archive.ubuntu.com/ubuntu/dists/bionic/main/installer-amd64/' \
--network default,mac='52:54:00:00:00:02'

virt-install \
--name master-2.local.com \
--description "master-2.local.com" \
--os-type=Linux \
--os-variant=ubuntu18.04 \
--ram=4096 \
--vcpus=2 \
--disk path=/var/lib/libvirt/images/master-2.img,bus=virtio,size=30 \
--graphics none \
--noautoconsole \
--console pty,target_type=serial \
--extra-args="ks=file:/kickstart.ks console=ttyS0,115200n8 serial" \
--initrd-inject="/home/chris/Documents/kubeadm/kickstart.ks" \
--location 'http://gb.archive.ubuntu.com/ubuntu/dists/bionic/main/installer-amd64/' \
--network default,mac='52:54:00:00:00:03'

virt-install \
--name master-3.local.com \
--description "master-3.local.com" \
--os-type=Linux \
--os-variant=ubuntu18.04 \
--ram=4096 \
--vcpus=2 \
--disk path=/var/lib/libvirt/images/master-3.img,bus=virtio,size=30 \
--graphics none \
--noautoconsole \
--console pty,target_type=serial \
--extra-args="ks=file:/kickstart.ks console=ttyS0,115200n8 serial" \
--initrd-inject="/home/chris/Documents/kubeadm/kickstart.ks" \
--location 'http://gb.archive.ubuntu.com/ubuntu/dists/bionic/main/installer-amd64/' \
--network default,mac='52:54:00:00:00:04'

virt-install \
--name worker-1.local.com \
--description "worker-1.local.com" \
--os-type=Linux \
--os-variant=ubuntu18.04 \
--ram=4096 \
--vcpus=2 \
--disk path=/var/lib/libvirt/images/worker-1.img,bus=virtio,size=30 \
--graphics none \
--noautoconsole \
--console pty,target_type=serial \
--extra-args="ks=file:/kickstart.ks console=ttyS0,115200n8 serial" \
--initrd-inject="/home/chris/Documents/kubeadm/kickstart.ks" \
--location 'http://gb.archive.ubuntu.com/ubuntu/dists/bionic/main/installer-amd64/' \
--network default,mac='52:54:00:00:00:05'

virt-install \
--name worker-2.local.com \
--description "worker-2.local.com" \
--os-type=Linux \
--os-variant=ubuntu18.04 \
--ram=4096 \
--vcpus=2 \
--disk path=/var/lib/libvirt/images/worker-2.img,bus=virtio,size=30 \
--graphics none \
--noautoconsole \
--console pty,target_type=serial \
--extra-args="ks=file:/kickstart.ks console=ttyS0,115200n8 serial" \
--initrd-inject="/home/chris/Documents/kubeadm/kickstart.ks" \
--location 'http://gb.archive.ubuntu.com/ubuntu/dists/bionic/main/installer-amd64/' \
--network default,mac='52:54:00:00:00:06'



exit 0


#virsh undefine lb.local.com --remove-all-storage
#virsh undefine master-1.local.com --remove-all-storage
#virsh undefine master-2.local.com --remove-all-storage
#virsh undefine master-3.local.com --remove-all-storage
#virsh undefine worker-1.local.com --remove-all-storage
#virsh undefine worker-2.local.com --remove-all-storage

#for i in lb master-1 master-2 master-3 worker-1 worker-2; \
# do; \
# virsh start $i ; \
# done
