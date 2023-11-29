#! /usr/bin/bash
# shellcheck disable=SC2317

## Deployment demo
kubectl create deployment hello-world --image=psk8s.azurecr.io/hello-app:1.0
kubectl get pods
# returns:
# NAME                          READY   STATUS    RESTARTS   AGE
# hello-world-9c69dc898-m68sv   1/1     Running   0          10s
#
# Corresponds to:
# NAME
# <deployment-name>-<pod-template-hash>-<unique-identifier>
# -> pod template hash is unique amongst ReplicaSets within a deployment
kubectl get ReplicaSet
# returns:
# NAME                    DESIRED   CURRENT   READY   AGE
# hello-world-9c69dc898   1         1         1       3m37s
kubectl get deployment
# returns:
# NAME          READY   UP-TO-DATE   AVAILABLE   AGE
# hello-world   1/1     1            1           4m10s

## containers running on node demo
# find which node is running the pod
kubectl get pods -o wide
# returns:
# NAME                          READY   STATUS    RESTARTS   AGE    IP               NODE       NOMINATED NODE   READINESS GATES
# hello-world-9c69dc898-m68sv   1/1     Running   0          6m3s   172.16.222.193   c1-node1   <none>           <none>
#
# Retrieve the NODE field and ssh into it
vagrant ssh c1-node1
# Then ps all the containers
sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock ps
# returns:
# CONTAINER           IMAGE               CREATED             STATE               NAME                ATTEMPT             POD ID              POD
# 3d4b06fa1f701       dd1b12fcb6097       7 minutes ago       Running             hello-app           0                   97237316db249       hello-world-9c69dc898-m68sv
# a38242d88284f       44f52c09decec       16 minutes ago      Running             calico-node         0                   0bf783833a038       calico-node-t4pvh
# ad52b86e4e0ed       f78ccdf8cb8c5       17 minutes ago      Running             kube-proxy          0                   a753b0928eddc       kube-proxy-r4bpt
exit

## Retrieve logs from pod
# Deploy a bare pod for ease of use (so we don't have to specify the unique ids)
kubectl run hello-world-pod --image=psk8s.azurecr.io/hello-app:1.0
kubectl logs pods/hello-world-pod
# returns:
# 2023/11/24 8:55:36 Server listening on port 8080
# 2023/11/24 8:55:36 Serving request: /

## start process inside a pod
kubectl exec -it hello-world-pod -- /bin/sh
# We are now in a shell inside the pod, where we can run other commands, such as
hostname
ip addr
# Now exite the shell
exit

## Expose the deployment
# --port is the port through which other resources can connect to the service
# --target-port is the port on the pod that is targeted by the service
kubectl expose deployment hello-world --port 80 --target-port 8080
# If both the port and target ports are kept the same, the above can be simplified to
# kubectl expose deployment hello-world --port 80
kubectl get service hello-world
# returns:
# NAME          TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
# hello-world   ClusterIP   172.17.7.204   <none>        80/TCP    3m52s

# Access the service (from one of the node as it won't be avilable outside of the cluster)
vagrant ssh c1-node1
# using cluster ip and port from before
curl http://172.17.7.204:80
# returns:
# Hello, world!
# Version: 1.0.0
# Hostname: hello-world-9c69dc898-m68sv

kubectl describe service hello-world
# returns:
# Name:              hello-world
# Namespace:         default
# Labels:            app=hello-world
# Annotations:       <none>
# Selector:          app=hello-world
# Type:              ClusterIP
# IP Family Policy:  SingleStack
# IP Families:       IPv4
# IP:                172.17.7.204
# IPs:               172.17.7.204
# Port:              <unset>  80/TCP
# TargetPort:        8080/TCP
# Endpoints:         172.16.222.193:8080
# Session Affinity:  None
# Events:            <none>
#
# "Endpoints" in the above output lists the endpoints to which traffic coming into the service gets redirected, i.e. the pod IP and port.
# Since there is only one pod here, there is also only one endpoint
kubectl get endpoints hello-world
# returns:
# NAME          ENDPOINTS             AGE
# hello-world   172.16.222.193:8080   5m36s
#
# When there are more pods as part of a deployment, the service contains additional endpoints for each of the additional pods
# And kube-proxy is then responsible for load balancing traffic between pods

## Return yaml manifest of our deployment + runtime information
kubectl get deployment hello-world -o yaml
# this returns the manifest as stated, but also a lot of runtime information, making the output less useful for re-using later as we have to remove all of the runtime information

## Delete all
# Check what we have first
kubectl get all
# Then nuke everything
kubectl delete all --all
# and exit ssh
exit

## Create a yaml manifest quickly
# CHeck in terminal
kubectl create deployment hello-world \
    --image=psk8s.azurecr.io/hello-app:1.0 \
    --dry-run=client -o yaml | less
# Write to an example file
kubectl create deployment hello-world \
    --image=psk8s.azurecr.io/hello-app:1.0 \
    --dry-run=client -o yaml > 02-deployment.yaml
# Apply file as is
kubectl apply -f 02-deployment.yaml

# This can also be done for the service
kubectl expose deployment hello-world \
    --port 80 --target-port 8080 \
    --dry-run=client -o yaml > 02-service.yaml
kubectl apply -f 02-service.yaml

# Check everything
kubectl get all

## Using this technique, we can modify the same resource by re-applying 
# Update the yaml file
sed -i 's/  replicas: 1/  replicas: 20/' 02-deployment.yaml
# Then re-apply
kubectl apply -f 02-deployment.yaml
# Check change
kubectl get deployment hello-world
# returns:
# NAME          READY   UP-TO-DATE   AVAILABLE   AGE
# hello-world   20/20   20           20          8m40s

# We can also now see that the service has more endpoints, one per pod to be precise
kubectl get endpoints hello-world
# returns:
# NAME          ENDPOINTS                                                            AGE
# hello-world   172.16.131.2:8080,172.16.131.3:8080,172.16.131.4:8080 + 17 more...   7m12s

## There are other ways to make edits
# For any kind of edit
kubectl edit deployment hello-world
# For re-scaling, aka modifying the number of replicas
kubectl scale deployment hello-world --replicas 15

# Clean the resources
kubectl delete deployment hello-world
kubectl delete service hello-world
# Check
kubectl get all