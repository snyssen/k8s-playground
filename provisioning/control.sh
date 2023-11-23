#! /usr/bin/bash

set -euxo pipefail

sudo kubeadm init \
    --apiserver-advertise-address="$CONTROL_IP" \
    --apiserver-cert-extra-sans="$CONTROL_IP" \
    --pod-network-cidr="$POD_CIDR" \
    --service-cidr="$SERVICE_CIDR"

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

curl "https://raw.githubusercontent.com/projectcalico/calico/v$CALICO_VERSION/manifests/calico.yaml" -O
kubectl apply -f calico.yaml