#! /usr/bin/bash

# This is the default context. It was filled from the kubeadm init command
kubectl config get-contexts
kubectl config use-context kubernetes-admin@kubernetes
kubectl cluster-info

# List available API resources
kubectl api-resources | less
# From a specific API group
kubectl api-resources --api-group=apps

# List all API versions
kubectl api-versions

# Get documentation of a specific resource
kubectl explain pods | less
# We can get further documentation on specific fields
kubectl explain pods.spec | less
kubectl explain pods.spec.containers | less
# Finally, we can get the entire definition at once
kubectl explain pods --recursive | less

# Get documentation for a specific version
kubectl explain deployment --api-version apps/v1

# Bare pod for demo
kubectl run hello-world --image=psk8s.azurecr.io/hello-app:1.0

# Increase verbosity on a request
# Show API requests info
kubectl get pod hello-world -v 6
# returns:
# I1129 11:15:10.798725  140357 loader.go:373] Config loaded from file:  /home/snyssen/source/repos/k8s-playground/.config/config
# I1129 11:15:10.811549  140357 round_trippers.go:553] GET https://192.168.56.20:6443/api/v1/namespaces/default/pods/hello-world 200 OK in 7 milliseconds
# NAME          READY   STATUS    RESTARTS   AGE
# hello-world   1/1     Running   0          3s

# Add request headers:
kubectl get pod hello-world -v 7
# Add response headers and truncated body:
kubectl get pod hello-world -v 8
# Add full response
kubectl get pod hello-world -v 9

# Interact with API server directly by proxying requests through kubectl (so they get authenticated properly)
kubectl proxy &
curl http://localhost:8001/api/v1/namespaces/default/pods/hello-world
# Stop the proxy server by bringing it back in foreground and killing it
fg

# Test with watch command
kubectl get pods -w -v 6 &
# Notice how the watch request from the above command adds an additional "resourceVersion" query param to the request. e.g.
# https://192.168.56.20:6443/api/v1/namespaces/default/pods?resourceVersion=76329&watch=true
# This parameter is used to pin the current state of the resource, so it can now when a new change has happened (since changes to the resource will change its resourceVersion)
# A TCP connection is kept open for kubectl to receive updates from the API server
netstat -tunapl | grep kubectl
# Check what happens when making changes
kubectl delete pods hello-world
kubectl run hello-world --image=psk8s.azurecr.io/hello-app:1.0
# Kill the watch
fg

# Test with logs
kubectl logs hello-world -v 6
# We can see a first request checking if the resource is alive and well, then a second to actually get the logs. e.g.
# I1129 11:37:57.556070  154956 round_trippers.go:553] GET https://192.168.56.20:6443/api/v1/namespaces/default/pods/hello-world 200 OK in 8 milliseconds
# I1129 11:37:57.571051  154956 round_trippers.go:553] GET https://192.168.56.20:6443/api/v1/namespaces/default/pods/hello-world/log?container=hello-world 200 OK in 13 milliseconds
# What if we follow the logs?
kubectl logs hello-world -v 6 -f &
# Not a big surporise here, it basically works exactly like the -w flag: it adds a new query parameter (follow=true) and keeps a TCP connection open
netstat -tunapl | grep kubectl
fg

# The k8s api server is a RESTful API server, so you can expect everything done by kubectl to respect the specs, e.g.
# - Requests to the API are made using standard HTTP methods:
#   - GET for querying resources
#   - POST to create them
#   - PUT and PATCH to update them
#   - DELETE to remove them
# - Responses status code are specific to errors:
#   - 404 for non-existing resources
#   - 401 for unauthenticated requests
#   - 403 for unauthorized requests
#   - 500 for errors with the server
#   - etc.