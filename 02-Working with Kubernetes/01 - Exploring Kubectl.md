# Create manifests rapidly
The `--dry-run` flag can be used to rapidly output yaml manifests from imperative commands do they can later be updated and used in declarative commands (i.e. `kubectl apply -f file.yaml`). Example:
```sh
kubectl create deployment hello-world \
--image=gcr.io/google-samples/hello-app:1.0 \
--dry-run=client -o yaml > file.yaml
```

# Application deployment process
Here is what the API server is doing when creating a deployment:
1. `kubectl apply` sends a *manifest* (e.g. a deployment) to the *API server*.
2. The *API server* parses the information stored in the *manifest* and stores the requested objects into *etcd*.
3. The *Controller Manager* is watching *etcd* for any new objects it needs to know about. Defining a *deployment* will instruct it to create a controller for it that will in turn create a replica set. The replica set will create the number of pods required by the deployment, and write their definition back into *etcd*.
4. The *scheduler* is watching *etcd* for pods that haven't been assigned to nodes yet. When it does find some, it will schedule them, i.e. it will assign them a node they should run on. It will update their definition and write it back into *etcd*. **At this point, not pod has started yet**.
5. The *Kubelet* on each node is constantly asking the *API Server* about work it needs to do. The *API Server* thus now responds with the newly created pod that have been assigned to the node asking it for work.
6. Once the *Kubelet* receives the pod definitions, it will send a message to the *container runtime* (on the same node) to pull down the container images specified on the pod spec, and to start the pod on the node. If the pod is part of a service, then the *kube-proxy* on the node is also updated to be able to route requests to the pod.

This workflow is for a deployment, and may differ slightly for other definitions.