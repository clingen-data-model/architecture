# Argo

Helm charts can be added to argo for UI monitoring and syncing of deployed kubernetes objects with those specified in a github repository.

## Argo Applications

Argo applications are bundles of kubernetes resources related to a single "application". They consist of a helm chart, one or more helm values files that get filled into fields in the helm chart templated kubernetes manifests, and a number of overrides and argo config and metadata.

For example an application might be `anyvar_v1.0.1`, which consists of a kubernetes pod with an init container that loads snapshot data and another container running the anyvar codebase, a storage disk, a kubernetes network service, and an ingress connected to an external IP address and TLS certificate. The application would say to use the anyvar helm chart and a values file that tells the helm chart what code version to run and what version of snapshot to load. Another application could be created, like `anyvar_v2.0.0a`, that uses the same anyvar helm chart, with a different values file that points to a different code version.

Argo Applications are Kubernetes custom resources.

```
apiVersion: argoproj.io/v1alpha1
kind: Application
... etc
```

They can be added as yaml through the Argo UI, where they are automatically added into the same kubernetes cluster the UI is running in, and in the same kuberenetes namespace. We are using the kubernetes namespace `argocd` for everything Argo. They can also be added (using the same yaml) from the command line with:

```
kubectl apply -f <app-file.yaml> --namespace argocd
```

Installed applications visible on the Argo UI can also be seen with:
```
kubectl get applications --namespace argocd
```
