#! /usr/bin/bash

# Get namespaces
kubectl get namespaces

# Get resource that are namespaced
kubectl api-resources --namespaced=true
# And thos that are not
kubectl api-resources --namespaced=false

# Get more info on all namespaces
kubectl describe namespaces
# And on a specific one
kubectl describe namespaces default

# Get resources accross namespaces
kubectl get pods --all-namespaces
# Or abbreviated as
k get po -A
# Get all the resources across the entire cluster
k get all -A

# Get resources in a specific namespace
kubectl get pods --namespace kube-system
# Or abbreviated as
k get po -n kube-system

# Create a namespace imperatively
k create ns playground1
# Namespaces names can only consist of lower case letters, numbers, and dashes
# k create ns Playground <- This is invalid
# Check the manifest
k create ns playground1 --dry-run=client -o yaml

# Create a namespaced pod
k run hello-world-pod \
    --image=gcr.io/google-samples/hello-app:1.0 \
    --namespace playground1
# Check pod
k get po -n playground1

# Destroy all resources of a kind in a namespace
k delete po -n playground1 --all
# Destroy the namespace itself, which also delete all of the resources that were still inside it
k delete ns playground1
