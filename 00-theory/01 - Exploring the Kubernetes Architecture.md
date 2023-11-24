# Introduction
Kubernetes is a declarative container orchestrator, workload placement and infrastructure abstraction. It should try to reach a declared desired state.

k8s works by receiving a desired state and combining it with control loops (in controllers) to check if the current state corresponds to the desired one, and update it if it does not. controllers make change to the system to reach the desired state. The desired state is defined through the K8s API.

The state is defined using API objects. The API is a RESTful API over HTTP using JSON. It is the sole way to interact with the cluster, and the sole way K8s interacts with it too. The objects that transit through the API are serialized and save into the cluster datastore (etcd).

Main k8s API Objects:
- Pods = single unit, collection of containers that run on a node
- Controllers = ReplicaSets, Deployments, etc., they dictate the desired state
- Services = provide consistent access to pods, no matter if they get redeployed 
- Storage = abstraction over storage (often persistent)
- Above is not exhaustive, but these are the most important objects

# K8S main objects
## Pods
![[Pasted image 20231114104000.png]]
Atomicity means that even if a single container fails inside a pod, the whole pod fails
## Controllers
Define desired state and ensure it is respected.
- ReplicaSet = manage a number of replicas of a pod
- Deployment = manages ReplicaSets, and the transition between ReplicaSets, e.g. upgrades of app version
![[Pasted image 20231114104558.png]]
## Services
![[Pasted image 20231114104727.png]]

## Storage
Initially there were only volumes, which were directly tied to pods. Since this was limiting, k8s added persistent volumes, that offers a cluster-wide abstraction over storage. Persitent volume claim

# Cluster components
- Control Plane Node = Coordinates cluster operations, monitoring, pods scheduling, and is the primary access point for operations
- Node (or "worker node") = Run the pods, and the containers inside of those. They handle networking to ensure reachability of pods. Each node contribute to the computing capacity of the cluster.
## Control Plane Node
![[Pasted image 20231114110424.png]]
Components of the Control Plane Node:
1. API Server = handles API requests to the clusters
2. ETCD = storage of the cluster state
3. Scheduler = handles scheduling of pods e.g. on which node they should be deployed based on relevant properties
4. Controller Manager = Handles the lifecycle of the controllers => Keep things in the desired state
kubectl is used to interact with the API Server.
Responsibilities of those components:
![[Pasted image 20231114111015.png]]
## Node
![[Pasted image 20231114111519.png]]
Components of a worker node:
1. Kubelet = starts pods on the node, and reports state to API Server
2. kube-proxy = pod networking and implementation of services abstractions on the node itself
3. container runtime = pulls the container images and run them
kubelet and kube-proxy both monitor the API server for changes
Responsibilities of the node components:
![[Pasted image 20231114112113.png]]
These run on **all** nodes, even the control plane node!
# Cluster Add-on pods
Kubernetes will run some add-on pods by default to support some of its functionalities, such as DNS, Ingress or Dashboard.
# Operations
![[Pasted image 20231114112744.png]]
1. kubectl asks for a new deployment to the API Server
2. The API Server
	1. Saves the state to etcd
	2. Asks the scheduler onto which node should the pods be created
	3. Asks the controller manager for the creation of controllers
3. kubelet and kube-proxy both asks the API server frequently for what work they should be doing. The API Server according to the desired state set by its underlying components
4. kubelet reflects the work given by the API Server by creating the necessayr pods
5. kube-proxy does the same for services
6. The container runtime handles the operations of the individual containers inside the pods
If a node goes down, it stops reporting its state, and the controller manager understands that it needs to update the number of replicas. It asks the schedfuler to schedule the pods that are needed to reach back the desired state.
The control plane node is by default tainted so it only accepts system pods. It can be untainted so it can run any pod, but this is not recommended.
# Kubernetes networking
In a cluster, each pod gets its unique IP address. There are two mandatory rules to respect when implementing a Kubernetes cluster:
- Pods on a Node can communicate with all pods on all nodes, without Network Address Translation
- Agents (such as system daemons and the kubelet) on a node can communicate with all pods on that node
There are 4 scenarios of communication:
![[Pasted image 20231114114225.png]]
1.  container to container inside a pod => can be done through localhost (using namespaces)
2. pod to pod, within a node => can use a bridged network (layer 2 software bridge), using the IP addresses of the pods
3. pod to pod, between nodes => Needs layer 2 or 3 connectivity between the pods, then uses pods IP addresses (can use an overlay network)
4. expose service to the web => use of kube-proxy (and services managed by it)
Above is only scratching the surface, a dedicated lesson on Kubernetes networking is coming.