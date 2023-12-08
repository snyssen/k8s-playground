# Static pods
- Are managed by Kubelet on the nodes
- Are instantiated from static pods manifests, i.e. manifest files located on disk at the path defined in `staticPodPath` in the Kubelet's configuration
	- Default value is `/etc/kubernetes/manifests`
	- The kubelet config can be found at `/var/lib/kubelet/config.yaml`
	- That path is watched, so any change in it is immediately reflected
- Are managed by the kubelet instead of the API Server
	- Mirror pods are created so the API server can see the static pods, but cannot interact with them

# Multi containers pods
- Containers inside a pod share the same network namespace:
	- So they can communicate through localhost
	- But they also cannot use the same ports
- Each container has its own filesystem
- Volumes are defined at the pod level, meaning they are shared between containers, and can be mounted by any container