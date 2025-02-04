# prepare
mkdir -p ~/.local/bin
cd /tmp

# pipx
sudo apt update
sudo apt install pipx
pipx ensurepath
bash

# ansible
pipx install --include-deps ansible
pipx install ansible-core

# kubectl
wget https://dl.k8s.io/release/v1.35.0/bin/linux/amd64/kubectl -O kubectl
chmod +x kubectl
mv kubectl ~/.local/bin/kubectl
cp ~/.local/bin/kubectl ~/.local/bin/k

# k9s
wget https://github.com/derailed/k9s/releases/download/v0.50.18/k9s_Linux_amd64.tar.gz -O k9s_Linux_amd64.tar.gz
tar -zxvf k9s_Linux_amd64.tar.gz
cp k9s ~/.local/bin
rm -rf k9s k9s_Linux_amd64.tar.gz LICENSE README.md

# helm
wget https://get.helm.sh/helm-v4.1.0-linux-amd64.tar.gz -O helm-linux-amd64.tar.gz
tar -zxvf helm-linux-amd64.tar.gz
cp linux-amd64/helm ~/.local/bin
rm -rf helm-linux-amd64.tar.gz linux-amd64

# yq
wget https://github.com/mikefarah/yq/releases/download/v4.52.2/yq_linux_amd64 -O yq
chmod +x yq
mv yq ~/.local/bin/yq

# terraform
wget https://releases.hashicorp.com/terraform/1.14.4/terraform_1.14.4_linux_amd64.zip -O terraform_linux_amd64.zip
unzip terraform_linux_amd64.zip
cp terraform ~/.local/bin
rm -rf terraform terraform_linux_amd64.zip LICENSE.txt

# opentofu
wget https://github.com/opentofu/opentofu/releases/download/v1.11.4/tofu_1.11.4_linux_amd64.tar.gz -O tofu_linux_amd64.tar.gz
tar -zxvf tofu_linux_amd64.tar.gz
cp tofu ~/.local/bin
rm -rf tofu tofu_linux_amd64.tar.gz CHANGELOG.md LICENSE README.md

# terragrunt
wget https://github.com/gruntwork-io/terragrunt/releases/download/v0.99.1/terragrunt_linux_amd64.tar.gz -O terragrunt_linux_amd64.tar.gz
tar -zxvf terragrunt_linux_amd64.tar.gz
mv terragrunt_linux_amd64 ~/.local/bin/terragrunt
chmod +x ~/.local/bin/terragrunt
rm -rf terragrunt_linux_amd64.tar.gz

# aws cli
wget https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -O awscliv2.zip
unzip awscliv2.zip
./aws/install \
  --install-dir $HOME/.aws-cli \
  --bin-dir $HOME/.local/bin
rm -rf aws awscliv2.zip
