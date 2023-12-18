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

## Controlling rollouts with Update Strategy
There are two update strategies available:
- RollingUpdate - (default), a new ReplicaSet starts scaling up while the old ReplicaSet starts scaling down
- Recreate - Terminates all pods in the current ReplicaSet then scale up a new ReplicaSet. This can be used for applications that cannot support a rolling update.

### Controlling the RollingUpdate Strategy
We can configure that strategy with the following args:
- maxUnavailable - (default 25%, can be a ratio or a number)  Ensures only a certain number of pods are unavailable during update
- maxSurge - (default 25%, can be a ratio or a number) Ensures only a certain number of pods are created above the desired number of pods

> Note: Readiness Probes are used to define when a pod is in a ready state during a rollout, so they are essential to a successful update

## Pausing and resuming rollouts
Pause a rollout:
```sh
kubectl rollout pause deployment hello-world
```

Resume a rollout:
```sh
kubectl rollout resume hello-world
```

## Rolling back an update
Kubernetes tracks rollout, specifically the cause, using annotations such as `CHANGE-CAUSE` on the Deployment. By default, it keeps an history of 10 revisions, but this can be adjusted with the `revisionHistoryLimit` parameter (can be set to 0 to disable). In concrete terms, a number of ReplicaSets are kept in history, allowing you to go back to a previous one.

We can see the history using:
```sh
kubectl rollout history deployment hello-world
```

Check info on a specific revision in history:
```sh
kubectl rollout history deployment hello-world --revision=1
```

Roll back to previous revision:
```sh
kubectl rollout undo deployment hello-world
```

Roll back to specific revision:
```sh
kubectl rollout undo deployment hello-world --revision=1
```

## Restarting a deployment
We can "restart" the pod by creating a new ReplicaSet with the same Pod Spec, replacing the previous ReplicaSet:
```sh
kubectl rollout restart deployment hello-world
```
The transition between the two ReplicaSets will respect your [[#Controlling rollouts with Update Strategy|defined update strategy]].