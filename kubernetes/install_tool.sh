# k9s
wget https://github.com/derailed/k9s/releases/download/v0.32.4/k9s_Linux_amd64.tar.gz
tar -zxvf k9s_Linux_amd64.tar.gz
sudo chmod +x k9s
sudo cp k9s /usr/local/bin

# helm
wget https://get.helm.sh/helm-v3.14.4-linux-amd64.tar.gz
tar -zxvf helm-v3.14.4-linux-amd64.tar.gz
sudo chmod +x linux-amd64/helm
sudo cp linux-amd64/helm /usr/local/bin

# yq
wget https://github.com/mikefarah/yq/releases/download/v4.43.1/yq_linux_amd64
mv yq_linux_amd64 yq
sudo chmod +x yq
sudo cp yq /usr/local/bin