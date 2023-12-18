# Updating a deployment
Updating a deployment will usually trigger a rollout, which will gradually rollout the changes over all of the replicas. For this purpose, the update deployment will create a new ReplicaSet which will begin the creation of the updated pods, while the older ReplicaSet gets removed and its pods get terminated. The ReplicaSet include a a pod template hash in their name, which means that changes in the PodTemplate section of the deployment hange the hash, making it easy to track changes. Changes outside the PodTemplate won't trigger a rollout, such as changes in the number of replicas.

## Making updates imperatively
Change the image:
```sh
kubectl set image deployment hello-world hello-world=hello-app:2.0
```

Change the image, but keep a record of the change (in the deployment annotations) so it can be be rolled back if needed:
```sh
kubectl set image deployment hello-world hello-world=hello-app:2.0 --record
```

Edit object directly:
```sh
kubectl edit deployment hello-world
```

## Check deployment status
Follow the rollout
```sh
kubectl rollout status deployment hello-world
```

Describe the deployment
```sh
kubectl describe deployment hello-world
```

### Possible deployment statuses
- Complete
- Progressing
- Failed