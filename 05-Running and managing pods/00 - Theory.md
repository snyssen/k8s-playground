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

# Init containers
- Run before main app, for setting it up
- Run to completion, and only then can the other container(s) start
- Can have more than one per pod, are run sequentially
- If init container fail, fails the entire pod and do not start the app

# Pod lifecycle
![[Pasted image 20231213094652.png]]
Pods are never "re-deployed", they are instead destroyed and recreated, i.e. a completely new instance is created each time.

When requesting the deletion of a pod, a grace period timer is launched (default: 30s). The pod status is changed to "terminating" and a SIGTERM is sent to the container(s), asking for shutdown. The pod is removed from the services and controllers it is part of. If the containers do not complete within the grace period, they get forcefully killed using SIGKILL.

## Container restart policy
- Containers can restart independently of the pod
- Use of exponential backoff on restarts. That backoff is reset to 0 after 10 min of successful runtime.
- There are 3 available restart policies:
	- Always - always restart containers when not running, no matter if they failed or simply finished
	- OnFailure - restarte containers that failed
	- Never - do not restart containers

## Defining pod health
- By default, a pod is considered when ready when all of its containers are ready
- Container probes provide a better way of defining what healthy is. There are three probes:
	- livenessProbe
	- readinessProbe
	- startupProbe
### Liveness probes
- per container
- on failure, restart the container according to policy
### Readiness probes
- per container
- define if app is ready to take requests, so app won't receive requests from service until probe succeeds
- On failure, remove pod from load balancing => protect app in case of temporary failure
### Startup probe
- per container
- on startup, all other probes are disabled until this one succeeds
- on failure, restart container according to policy
- Is useful for apps with long startup time
### Types of diagnostic checks for probes
- Exec - run a command in the container and process its exit code
- tcpSocket - try to open a port and report result
- httpGet - try to run an HTTP GET query in the container and check if the return code is >= 200 and < 400

### Probes parameters
- `initialDelaySeconds` - number of seconds after container has started before running the probe, default 0
- `periodSeconds` - probe interval, default 10
- `timeoutSeconds` - probe timeout, default 1
- `failureThreshold` - number of missed checks before reporting failure, default 3
- `successThreshold` - after reported failure, number of successful probes to report success, default 1