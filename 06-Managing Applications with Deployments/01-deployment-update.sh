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

# Set deployment deadline to 10 sec for demonstration, so we don't have to wait
k patch deployment hello-world -p '{"spec":{"progressDeadlineSeconds": 10}}'
# Then apply wrong update
k set image deployment hello-world hello-app=psk8s.azurecr.io/hello-app:2.9.9
k rollout status deployment hello-world
# Notice return status of 1
echo "$?"
# Notice that pods are failing because of the invalid image
# Also notice that there are still 8 functional pods on the 10 original because maxUnavailable is set to 25%
# Also notice that there are 13 pods in total because maxSurge is ar 25% (3 being 25% of 10 rounded up)
k get po

# We can check the rollout history
# The "CHANGE-CAUSE" column is left emptyu because we didn't specify the --record flag
k rollout history deployment hello-world
# We can get the changes of each revision
k rollout history deployment hello-world --revision=2
k rollout history deployment hello-world --revision=3
# Finally, we can rollback to a previous revision
k rollout undo deployment hello-world --to-revision=2
k rollout status deployment hello-world
# Check that we are back in normal conditions
k get po
