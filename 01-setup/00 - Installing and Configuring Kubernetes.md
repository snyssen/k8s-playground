# Pre-requisite
[[00 - OSI model and the 7 layers of networking]]

# Installation
![[Pasted image 20231114155044.png]]
## Ports requirements
![[Pasted image 20231114155303.png]]
- In the above table, first part is for opened ports on the control plan node, second is for worker nodes
- etcd to etcd connection is only required if etcd is deployed multiple times (for redundancy)
- "Self" here means that the specified component is only listening on localhost

## Components to install
These components should be installed on every node, no matter their intended role:
- containerd
- kubelet
- kubeadm
- kubectl
```sh
sudo apt-get install -y containerd
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl containerd
```

---

**After this point, notes and demo can be found at https://github.com/snyssen/k8s-playground **

---
# Cluster bootstrap
A cluster can be bootstrapped using the command `kubeadm init`. It then goes through all of the following steps:
![[Pasted image 20231115143126.png]]
1. Run of the `kubeadm init`
2. kubeadm checks if the node can be used in a k8s cluster
3. A CA is used to secure all communications within the clusters by creating a certificat for the API Server (that can thus secure communications using HTTPS). It is self-signed by default but can be customized to make use of an external PKI. It is also used to generate certificates to authenticate users and cluster components. You can find this CA et `/etc/kubernetes/pki`. The CA is copied to individual nodes that join the cluster so they trust it.
![[Pasted image 20231115143730.png]]
4. kubeconfig files are all of the configuration files of a k8s node. They can be found under `/etc/kubernetes` and consist mostly of:
	1. admin.conf (only on the control plane node)
	2. kubelet.conf
	3. controller-manager.conf
	4. scheduler.conf
5. Manifests are configuration files for pods. kubeadm generates manifests in `/etc/kubernetes/manifests` for the main components of the cluster:
	1. etcd
	2. API Server
	3. Controller manager
	4. Scheduler
	The kubelet watches this directory and start up the pods described by those manifets. This is how the node is hooked into systemd: at boot, the kubelet systemd unit is started, and it boots all of the pods defined by the manifests.

## Pod networking
As stated previously, K8S requires level 3 connectivity between all pods, with each pod having its own unique and un-NATed IP address. This is often not feasible, so we rely instead on overlay networks (also called software-defined networks). Some of the available overlay networks are:
![[Pasted image 20231115174036.png]]
In our cluster, we will be using **Calico**. The overlay network will provide the IP address for the pods, but it is very important that the adressable range of the overlay network does not overlap with other networks.
More information on k8s networking can be found at https://kubernetes.io/docs/concepts/cluster-administration/networking/

## Creating a control plane node
![[Pasted image 20231115180845.png]]
1. Download and generate config files for calico and the cluster
2. Init the control plane node using the cluster config and specifying the CRI socker
3. Give admin rights to the cluster to the currently logged user
4. Apply the calico configuration, which will create the addon pods for DNS in the cluster
## Adding a node to the cluster
![[Pasted image 20231115181227.png]]
1. Install the packages (same as control plane node - kubelet, kubeadm, kubectl, containerd).
2. Run `kubeadm join` to join the cluster. It requires some parameters that are provided by the control plane node.
3. Retrieve some information about the cluster, notably its general configuration.
4. Node submit a CSR to the control plane node so the latter can generate a certificate that is then used by kubelet in the worker node to authenticate against the API Server on the control plane node.
5. The CA signs the certificate following the CSR described above. Kubelet thus download the resulting certificate, and stores it locally at `/var/lib/kubelet/pki`.
6. Kubelet generates a kubelet.conf file and stores it at `/etc/kubernetes` in the worker node. That file stores a reference to the newly created certificate as well as the network location of the API Server.
This whole process is started with the following command:
![[Pasted image 20231115182157.png]]
This command is printed at the end of the `kubeadm init`, and can be printed again on demand (especially important since the token is time sensitive).