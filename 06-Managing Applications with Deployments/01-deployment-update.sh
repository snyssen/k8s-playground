#! /usr/bin/bash

# Create demo deployment
k create deployment hello-world --image=psk8s.azurecr.io/hello-app:1.0
# Scale it to 10
k scale deployment hello-world --replicas=10
# Check status. Notice how it gives us the number of replicas that are up-to-date and ready
k get deployment hello-world

# Update the image then immediately run the next command to observe the rollout
k set image deployment hello-world hello-app=psk8s.azurecr.io/hello-app:2.0
k rollout status deployment hello-world
# Notice how output states that replicas are updated individually, with old ones getting removed
# Get return code, notice how an exit code of 0 equals a successful rollout
echo "$?"
# Check status again, everything should be ready and up-to-date
k get deployment hello-world
# Get deployments details
k describe deployment hello-world
# Notice how it contains information about the replicas and the update strategy
# We can also see the revision number in the annotations
# Get ReplicaSets and notice the the old one is still present, with desired set to 0
k get replicasets

