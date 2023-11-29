#! /usr/bin/bash

## kubectl diff can be used to check the difference between a resource in the cluster an,d one defined in a manifest or stding
kubectl create deployment hello-world \
    --image=psk8s.azurecr.io/hello-app:1.0 \
    --dry-run=client -o yaml > 00-deployment.yaml
kubectl apply -f 00-deployment.yaml
sed -i 's/  replicas: 1/  replicas: 20/' 00-deployment.yaml
kubectl diff -f 00-deployment.yaml
# returns:
# diff -u -N /tmp/LIVE-4286932583/apps.v1.Deployment.default.hello-world /tmp/MERGED-2380479010/apps.v1.Deployment.default.hello-world
# --- /tmp/LIVE-4286932583/apps.v1.Deployment.default.hello-world 2023-11-24 15:31:28.296371215 +0100
# +++ /tmp/MERGED-2380479010/apps.v1.Deployment.default.hello-world       2023-11-24 15:31:28.296371215 +0100
# @@ -6,7 +6,7 @@
#      kubectl.kubernetes.io/last-applied-configuration: |
#        {"apiVersion":"apps/v1","kind":"Deployment","metadata":{"annotations":{},"creationTimestamp":null,"labels":{"app":"hello-world"},"name":"hello-world","namespace":"default"},"spec":{"replicas":1,"selector":{"matchLabels":{"app":"hello-world"}},"strategy":{},"template":{"metadata":{"creationTimestamp":null,"labels":{"app":"hello-world"}},"spec":{"containers":[{"image":"psk8s.azurecr.io/hello-app:1.0","name":"hello-app","resources":{}}]}}},"status":{}}
#    creationTimestamp: "2023-11-24T14:27:49Z"
# -  generation: 2
# +  generation: 3
#    labels:
#      app: hello-world
#    name: hello-world
# @@ -15,7 +15,7 @@
#    uid: c264f422-0294-4636-b9a6-339c0607da7a
#  spec:
#    progressDeadlineSeconds: 600
# -  replicas: 1
# +  replicas: 20
#    revisionHistoryLimit: 10
#    selector:
#      matchLabels: