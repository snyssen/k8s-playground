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

