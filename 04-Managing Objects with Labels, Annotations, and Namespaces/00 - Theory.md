# Namespaces
- Are used to subdivise a cluster and its resources
- Are conceptually a kind of "virtual cluster"
- Namespaces provide resource isolation and organization
- They provide:
	- Security boundaries for RBAC
	- Naming boundaries (resources can share an identical name when they are not in the same ns)
- A resource can only be in one ns
- This has nothing to do with Linux namespaces

Most objects are namespaced (Pods, Controllers, Services, etc.), but some are not (PersistentVolumes, Nodes => Physical "things")

Provided namespaces:
![[Pasted image 20231129135628.png]]

# Labels
- Are used to organize resources (pods, nodes, etc.)
- Can be targeted by Label Selectors to query resources
- Are used to influence internal operations of k8s, e.g.:
	- controllers and services match pods using selectors
	- Pod scheduling can be influenced by labels, e.g.:
		- scheduling to specific nodes
		- targeting specific hardware (SSD, GPU, etc.)
- Are non-hierarchical key/value pairs
- Keys must be less than 64 chars long
- Values must be less than 254 chars long

Examples of resources filtering using labels:
![[Pasted image 20231207153735.png]]

Example use case of labels and selectors: the relation between deployments, pods, and services.
![[Pasted image 20231207154659.png]]