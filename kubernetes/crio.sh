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

wget https://storage.googleapis.com/cri-o/artifacts/cri-o.amd64.v1.31.0.tar.gz
tar -zxvf cri-o.amd64.v1.31.0.tar.gz
sudo cp cri-o/bin/* /usr/local/bin

wget https://github.com/opencontainers/runc/releases/download/v1.2.0-rc.3/runc.amd64
sudo install -m 755 runc.amd64 /usr/local/sbin/runc

wget https://github.com/containernetworking/plugins/releases/download/v1.5.1/cni-plugins-linux-arm64-v1.5.1.tgz
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-arm64-v1.5.1.tgz
sudo mkdir -p /etc/cni/net.d

sudo mkdir -p /etc/crio
sudo crio config default | sudo tee /etc/crio/crio.conf

cat <<EOF | sudo tee /etc/systemd/system/crio.service
[Unit]
Description=CRI-O Container Runtime
Documentation=https://github.com/cri-o/cri-o
After=network.target

[Service]
ExecStart=/usr/local/bin/crio
Restart=on-failure
RestartSec=10s
LimitNOFILE=1048576
LimitNPROC=1048576
LimitCORE=infinity
TasksMax=infinity

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable crio
sudo systemctl start crio

sudo crictl config --set runtime-endpoint=unix:///run/crio/crio.sock
sudo crictl config --set image-endpoint=unix:///run/crio/crio.sock

sudo mkdir -p /etc/containers
cat <<EOF | sudo tee /etc/containers/policy.json
{
  "default": [
    {
      "type": "insecureAcceptAnything"
    }
  ],
  "transports": {
    "docker-daemon": {
      "": [
        {
          "type": "insecureAcceptAnything"
        }
      ]
    }
  }
}
EOF

wget https://dl.k8s.io/release/v1.31.0/bin/linux/amd64/kubectl
wget https://dl.k8s.io/release/v1.31.0/bin/linux/amd64/kubeadm
wget https://dl.k8s.io/release/v1.31.0/bin/linux/amd64/kubelet
wget https://raw.githubusercontent.com/kubernetes/release/v0.16.2/cmd/krel/templates/latest/kubelet/kubelet.service
wget https://raw.githubusercontent.com/kubernetes/release/v0.16.2/cmd/krel/templates/latest/kubeadm/10-kubeadm.conf

sudo chmod +x kubeadm kubelet kubectl
sudo cp kubeadm kubelet kubectl /usr/local/bin

sudo sed -i 's|/usr/bin/kubelet|/usr/local/bin/kubelet|g' kubelet.service
sudo cp kubelet.service /etc/systemd/system
sudo mkdir -p /etc/systemd/system/kubelet.service.d
sudo sed -i 's|/usr/bin/kubelet|/usr/local/bin/kubelet|g' 10-kubeadm.conf
sudo cp 10-kubeadm.conf /etc/systemd/system/kubelet.service.d/
sudo systemctl enable --now kubelet

sudo apt install -y socat conntrack

sudo kubeadm init --control-plane-endpoint=103.188.82.230  --apiserver-cert-extra-sans=103.188.82.230  --pod-network-cidr=192.168.0.0/16 --cri-socket=unix://var/run/crio/crio.sock

sudo kubeadm init --control-plane-endpoint=103.188.82.230  --apiserver-cert-extra-sans=103.188.82.230  --pod-network-cidr=10.85.0.0/16 --cri-socket=unix://var/run/crio/crio.sock

mkdir -p ~/.kube
sudo cp -i /etc/kubernetes/admin.conf ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
sudo chmod 600 ~/.kube/config

wget https://raw.githubusercontent.com/projectcalico/calico/v3.28.1/manifests/tigera-operator.yaml
wget https://raw.githubusercontent.com/projectcalico/calico/v3.28.1/manifests/custom-resources.yaml

kubectl create -f tigera-operator.yaml
kubectl create -f custom-resources.yaml

kubectl delete -f tigera-operator.yaml
kubectl delete -f custom-resources.yaml

kubectl taint nodes --all node-role.kubernetes.io/control-plane-

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm search repo bitnami

helm pull bitnami/nginx-ingress-controller --untar
helm pull bitnami/metrics-server --untar

helm repo add longhorn https://charts.longhorn.io
helm repo update
helm search repo longhorn

helm pull longhorn/longhorn --untar

kubectl create namespace nginx-ingress
kubectl create namespace longhorn-system

helm -n nginx-ingress install nginx-ingress-controller nginx-ingress-controller
helm -n kube-system install metric-server metrics-server

helm -n kube-system uninstall metric-server

sudo kubeadm reset --cri-socket=unix://var/run/crio/crio.sock
rm -rf ~/.kube


cat <<EOF | sudo tee /etc/cni/net.d/10-crio-bridge.conflist
{
  "cniVersion": "1.0.0",
  "name": "crio",
  "plugins": [
    {
      "type": "bridge",
      "bridge": "cni0",
      "isGateway": true,
      "ipMasq": true,
      "hairpinMode": true,
      "ipam": {
        "type": "host-local",
        "routes": [
            { "dst": "0.0.0.0/0" },
            { "dst": "::/0" }
        ],
        "ranges": [
            [{ "subnet": "10.85.0.0/16" }],
            [{ "subnet": "1100:200::/24" }]
        ]
      }
    }
  ]
}
EOF

