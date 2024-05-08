#!/bin/sh

mkdir -p /tmp/k9s
wget https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz -P /tmp/k9s
tar -zxf /tmp/k9s/k9s_Linux_amd64.tar.gz -C /tmp/k9s
sudo chmod +x /tmp/k9s/k9s
sudo cp /tmp/k9s/k9s /usr/local/bin
sudo chown $(id -u):$(id -g) /usr/local/bin/k9s
sudo rm -rf /tmp/k9s