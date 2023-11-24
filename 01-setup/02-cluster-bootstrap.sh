#! /usr/bin/bash
# shellcheck disable=SC2317

## SSH into control plane node
vagrant ssh c1-cp1

## Open the necessary ports in the firewall
# See: https://kubernetes.io/docs/reference/networking/ports-and-protocols/
# sudo ufw allow 6443/tcp
# Actually not needed in my VM since ufw is inactive per default

## Prepare calico overlay network
# Download the default manifest
wget https://raw.githubusercontent.com/projectcalico/calico/master/manifests/calico.yaml
# Check that the default IPV4 pool won't collide with your underlying network
grep -A 1 "CALICO_IPV4POOL_CIDR" calico.yaml
# If needed, update the value:
sed -i 's/            # - name: CALICO_IPV4POOL_CIDR/             - name: CALICO_IPV4POOL_CIDR/' calico.yaml
sed -i 's|            #   value: "192.168.0.0/16"|               value: "192.168.0.0/32"|' calico.yaml

## Bootstrap cluster
# A specific k8s version can optionnally be declared here by using '--kubernetes-version v1.26.0'
# But since we are already pinned a specific minor version using the appropriate apt repos,
# I don't mind the bootstrap simply looking for the latest patch version within that pinned minor version
# Address IP is provided explicitely since the VM has two IP and the default cannot be used for machine to machine communication
sudo kubeadm init --apiserver-advertise-address=192.168.56.20 --apiserver-cert-extra-sans=192.168.56.20
# I have logged my output in file 02-cluster-vootstrap.kubeadm-init.log

## Allow current user to administrate the cluster
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

## Add calico pod network
kubectl apply -f calico.yaml

## Checks
# Check all resources
kubectl get --all-namespaces all
# Check nodes
kubectl get nodes
# Check systemd unit for kubelet
systemctl status kubelet
# Notice that it is no longer in a crash loop since it can now contact the API Server
# List the static manifests. Notice how they correspond to the pods that have been deployed
ls /etc/kubernetes/manifests

## Exit ssh session
exit

#############################################################################################################################

## For each worker node, install packages as done previously for the control plane node
# Log into node 1
vagrant ssh c1-node1
# Then repeat steps from 01-packages-installation.sh
exit

# Log into node 2
vagrant ssh c1-node2
# Then repeat steps from 01-packages-installation.sh
exit

# Log into node 3
vagrant ssh c1-node3
# Then repeat steps from 01-packages-installation.sh
exit

## (optional) Get a token from the control plane node
# Log pack into it
vagrant ssh c1-cp1
# get the token
kubeadm token list
# If it has expired, generate a new one with
kubeadm token create

## (optional) Get the CA cert hash
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2> /dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'

## Instead of the two optional steps above, print the join command automatically
kubeadm token create --print-join-command
#! Copy the output before continuing
# Example output:
# kubeadm join 192.168.56.20:6443 --token vb7a3p.ni1elwoy5y5rgchu --discovery-token-ca-cert-hash sha256:cbe1017844d7fc7a30700daef136ca8fd4a9e475e954fcc28996c28406f4ae29

## Join cluster on node 1
exit
vagrant ssh c1-node1
# use the join command, e.g.:
sudo kubeadm join 192.168.56.20:6443 --token rbutuo.1381vit39x752tgo \
        --discovery-token-ca-cert-hash sha256:1aed1853c8b0fc3270f1d3e65a56d541f77cc69773148d1e5ee48209bf54878b