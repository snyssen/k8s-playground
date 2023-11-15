#! /usr/bin/bash

## SSH into control plane node
vagrant ssh c1-cp1

## Disable swap - was not actually needed with the VM I used since there was no swap to begin with
# swapoff -a
# You also need to update your /etc/fstab file and remove the line instructing the mount of the swap partition

## Installing and configuring pre-requisites
## https://kubernetes.io/docs/setup/production-environment/container-runtimes/#install-and-configure-prerequisites
### Forwarding IPv4 and letting iptables see bridged traffic
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

# Verify that modules are loaded
lsmod | grep br_netfilter
lsmod | grep overlay

# Verify that system variables are set
sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward

## Install containerd
sudo apt update
sudo apt install -y containerd

# Create containerd config file,
# and update it so containerd uses the systemd CGroup
# Why is this important? See: https://kubernetes.io/docs/setup/production-environment/container-runtimes/#cgroup-drivers
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/            SystemdCgroup = false/            SystemdCgroup = true/' /etc/containerd/config.toml
# Check if change was effective
grep -B 12 "SystemdCgroup" /etc/containerd/config.toml
# Above should return
#   [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
#     BinaryName = ""
#     CriuImagePath = ""
#     CriuPath = ""
#     CriuWorkPath = ""
#     IoGid = 0
#     IoUid = 0
#     NoNewKeyring = false
#     NoPivotRoot = false
#     Root = ""
#     ShimCgroup = ""
#     SystemdCgroup = true

# Restart containerd
sudo systemctl restart containerd

## Install Kubernetes packages - kubeadm, kubelet and kubectl
## https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
#! WARN: The Pluralsight uses the packages from https://apt.kubernetes.io, but the official doc has marked this repo as deprecated and recommends using https://pkgs.k8s.io instead
# I am thus following the official doc. Note that each Kubernetes version now have their own repository
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.26/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
# Then add packages list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.26/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
# Check available packages
apt-cache policy kubelet
# Above should return something like:
# kubelet:
#   Installed: (none)
#   Candidate: 1.26.10-1.1
#   Version table:
#      1.26.10-1.1 500
#         500 https://pkgs.k8s.io/core:/stable:/v1.26/deb  Packages
# [...]
# Install kubelet, kubeadm and kubectl, and pin their version
#* NOTE: no need to force install of a specific version since this is already taken care of by the specific apt repo
sudo apt-get install -y kubelet kubeadm kubectl
# Prevent automatic upgrades
# imo this should not be necessary since the apt repo already pins the k8s to a minor one, but I guess it is added for maximum stability, to even prevent automatic patch updates
sudo apt-mark hold kubelet kubeadm kubectl containerd

# Check systemd units
# Kubelet will report a status 1 failure. This is expected since it is waiting to be part of a k8s cluster
systemctl status kubelet
# containerd should be active
systemctl status containerd

# If they are inactive, start and enable them (so they start on reboot)
sudo systemctl start kubelet && sudo systemctl enable kubelet
sudo systemctl start containerd && sudo systemctl enable containerd