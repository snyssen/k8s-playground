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