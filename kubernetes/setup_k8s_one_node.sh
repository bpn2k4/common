wget https://github.com/containerd/containerd/releases/download/v1.7.15/containerd-1.7.15-linux-amd64.tar.gz
wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
wget https://github.com/opencontainers/runc/releases/download/v1.1.12/runc.amd64
wget https://github.com/containernetworking/plugins/releases/download/v1.4.1/cni-plugins-linux-amd64-v1.4.1.tgz
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.30.0/crictl-v1.30.0-linux-amd64.tar.gz
wget https://dl.k8s.io/release/v1.30.0/bin/linux/amd64/kubectl
wget https://dl.k8s.io/release/v1.30.0/bin/linux/amd64/kubeadm
wget https://dl.k8s.io/release/v1.30.0/bin/linux/amd64/kubelet
wget https://raw.githubusercontent.com/kubernetes/release/v0.16.2/cmd/krel/templates/latest/kubelet/kubelet.service
wget https://raw.githubusercontent.com/kubernetes/release/v0.16.2/cmd/krel/templates/latest/kubeadm/10-kubeadm.conf
wget https://raw.githubusercontent.com/projectcalico/calico/v3.27.3/manifests/tigera-operator.yaml
wget https://raw.githubusercontent.com/projectcalico/calico/v3.27.3/manifests/custom-resources.yaml

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system


sudo tar -zxf containerd-1.7.15-linux-amd64.tar.gz -C /usr/local
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo mkdir -p /usr/local/lib/systemd/system
sudo cp containerd.service /usr/local/lib/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable --now containerd 
sudo install -m 755 runc.amd64 /usr/local/sbin/runc
sudo mkdir -p /opt/cni/bin
sudo tar -zxf cni-plugins-linux-amd64-v1.4.1.tgz -C /opt/cni/bin
sudo mkdir -p /etc/cni/net.d
sudo systemctl restart containerd

sudo tar -zxf crictl-v1.30.0-linux-amd64.tar.gz -C /usr/local/bin
sudo crictl config --set runtime-endpoint=unix:///run/containerd/containerd.sock
sudo crictl config --set image-endpoint=unix:///run/containerd/containerd.sock
sudo chmod +x kubeadm kubelet kubectl
sudo cp kubeadm kubelet kubectl /usr/local/bin
sudo sed -i 's|/usr/bin/kubelet|/usr/local/bin/kubelet|g' kubelet.service
sudo cp kubelet.service /etc/systemd/system
sudo mkdir -p /etc/systemd/system/kubelet.service.d
sudo sed -i 's|/usr/bin/kubelet|/usr/local/bin/kubelet|g' 10-kubeadm.conf
sudo cp 10-kubeadm.conf /etc/systemd/system/kubelet.service.d/
sudo systemctl enable --now kubelet

sudo apt install -y socat conntrack

sudo kubeadm init --control-plane-endpoint=10.124.71.200  --apiserver-cert-extra-sans=10.124.71.200  --pod-network-cidr=192.168.0.0/16

mkdir -p ~/.kube
sudo cp -i /etc/kubernetes/admin.conf ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
sudo chmod 600 /home/ubuntu/.kube/config

kubectl create -f tigera-operator.yaml
kubectl create -f custom-resources.yaml

kubectl taint nodes --all node-role.kubernetes.io/control-plane-