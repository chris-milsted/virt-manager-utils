for instance in worker-1.local.com worker-2.local.com; do
  scp kube-proxy.kubeconfig ubuntu@${instance}:~/
done

for instance in master-1.local.com master-2.local.com master-3.local.com; do
  scp admin.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig ubuntu@${instance}:~/
done

for instance in master-1.local.com master-2.local.com master-3.local.com; do
  scp encryption-config.yaml ubuntu@${instance}:~/
done

ansible -b -i ../inventory.ansible -m command -a "apt install wget" masters
ansible -b -i ../inventory.ansible -m command -a 'wget -q --show-progress --https-only --timestamping "https://github.com/coreos/etcd/releases/download/v3.4.7/etcd-v3.4.7-linux-amd64.tar.gz"' masters

ansible -b -i ../inventory.ansible -m command -a 'tar xzf etcd-v3.4.7-linux-amd64.tar.gz' masters
ansible -b -i ../inventory.ansible -m command -a 'mv etcd-v3.4.7-linux-amd64/etcd /usr/local/bin/' masters
ansible -b -i ../inventory.ansible -m command -a 'mv etcd-v3.4.7-linux-amd64/etcdctl /usr/local/bin/' masters

ansible -b -i ../inventory.ansible -m command -a 'mkdir -p /etc/etcd /var/lib/etcd' masters

ansible -b -i ../inventory.ansible -m command -a 'mkdir -p /etc/kubernetes/config' masters

ansible -b -i ../inventory.ansible -m command -a "wget -q https://storage.googleapis.com/kubernetes-release/release/v1.18.1/bin/linux/amd64/kube-apiserver" masters
ansible -b -i ../inventory.ansible -m command -a "wget -q https://storage.googleapis.com/kubernetes-release/release/v1.18.1/bin/linux/amd64/kube-controller-manager" masters
ansible -b -i ../inventory.ansible -m command -a "wget -q https://storage.googleapis.com/kubernetes-release/release/v1.18.1/bin/linux/amd64/kube-scheduler" masters
ansible -b -i ../inventory.ansible -m command -a "wget -q https://storage.googleapis.com/kubernetes-release/release/v1.18.1/bin/linux/amd64/kubectl" masters

ansible -b -i ../inventory.ansible -m command -a 'mkdir -p /var/lib/kubernetes/' masters

ansible -b -i ../inventory.ansible -m command -a 'mv kube-scheduler.kubeconfig /var/lib/kubernetes/' masters

ansible -b -i ../inventory.ansible -m command -a 'mv kube-controller-manager.kubeconfig /var/lib/kubernetes/' masters

ansible -b -i ../inventory.ansible -m command -a 'systemctl daemon-reload' masters
ansible -b -i ../inventory.ansible -m command -a 'systemctl enable kube-apiserver kube-controller-manager kube-scheduler' masters
ansible -b -i ../inventory.ansible -m command -a 'systemctl stop kube-apiserver kube-controller-manager kube-scheduler' masters
ansible -b -i ../inventory.ansible -m command -a 'systemctl start kube-apiserver kube-controller-manager kube-scheduler' masters

ansible -i ../inventory.ansible -m command -a  'kubectl get componentstatuses --kubeconfig admin.kubeconfig' masters

ansible -b -i ../inventory.ansible -m command -a 'apt-get update -y' lb 
ansible -b -i ../inventory.ansible -m command -a 'apt-get install -y haproxy' lb

wget -q --show-progress --https-only --timestamping \
  https://storage.googleapis.com/kubernetes-release/release/v1.18.1/bin/linux/amd64/kubectl \
  https://storage.googleapis.com/kubernetes-release/release/v1.18.1/bin/linux/amd64/kube-proxy \
  https://storage.googleapis.com/kubernetes-release/release/v1.18.1/bin/linux/amd64/kubelet