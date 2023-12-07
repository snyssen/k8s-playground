#! /usr/bin/bash

# Recreate a deployment for testing
k create deployment hello-world --image=psk8s.azurecr.io/hello-app:1.0
# Show labels of pod
k get po --show-labels
# Query using selectors
k get po --selector app=hello-world
# can be more concise
k get po -l app=hello-world

# Create a second deployment with another name
k create deployment hello-universe --image=psk8s.azurecr.io/hello-app:1.0
# And label to all pods
k label po --all custom-label=true
# More complex queries
k get po -l "custom-label=true,app!=hello-world" --show-labels
k get po -l "app in (hello-world,hello-universe)"
k get po -l "custom-label notin (false)"
# Add column with label in output
k get po -L app
k get po -L app,custom-label
# Edit existing label
k label po hello-universe-5f9d76f658-d9hgb custom-label=false --overwrite
k get po -L custom-label
# remove label
k label po hello-universe-5f9d76f658-d9hgb custom-label-
k get po -L custom-label
# Selectors can be used on operations
k delete po -l app=hello-world
k get po --show-labels
# Output: no more labels!
