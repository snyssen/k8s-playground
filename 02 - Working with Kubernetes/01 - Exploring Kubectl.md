# Create manifests rapidly
The `--dry-run` flag can be used to rapidly output yaml manifests from imperative commands do they can later be updated and used in declarative commands (i.e. `kubectl apply -f file.yaml`). Example:
```sh
kubectl create deployment hello-world \
--image=gcr.io/google-samples/hello-app:1.0 \
--dry-run=client -o yaml > file.yaml
```

# Application deployment process
TODO: [Application and Pod Deployment in Kubernetes and Working with YAML Manifests](https://app.pluralsight.com/ilx/video-courses/9f2f79a1-8408-4c5a-8060-e424161dc54e/d4031324-4e16-49d8-9665-4b842eb320b1/633aa541-cd47-4007-a089-1b4f6a8e8a97) @8:56