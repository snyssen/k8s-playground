#! /usr/bin/bash

set -euxo pipefail

# TODO: use IP address and CIDRs from settings
sudo kubeadm init --apiserver-advertise-address=192.168.56.20 --apiserver-cert-extra-sans=192.168.56.20 --pod-network-cidr=172.16.1.0/16 --service-cidr=172.17.1.0/18

# Copy config for root
mkdir -p "$HOME"/.kube
sudo cp -i /etc/kubernetes/admin.conf "$HOME"/.kube/config
sudo chown "$(id -u)":"$(id -g)" "$HOME"/.kube/config

# Copy config for vagrant user (the one with which you SSH)
sudo -i -u vagrant bash << EOF
mkdir -p "/home/vagrant/.kube"
sudo cp /etc/kubernetes/admin.conf "/home/vagrant/.kube/config"
sudo chown 1000:1000 "/home/vagrant/.kube/config"
EOF

# /vagrant is a mounted directory inside VMs that points to the project directory on the host
config_path="/vagrant/.config"
if [ -d $config_path ]; then
  rm -f $config_path/*
else
  mkdir -p $config_path
fi

cp /etc/kubernetes/admin.conf $config_path/config
touch $config_path/join.sh
chmod +x $config_path/join.sh
kubeadm token create --print-join-command > $config_path/join.sh

# TODO: use version from settings
curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.0/manifests/calico.yaml -O
kubectl apply -f calico.yaml