# ArgoCD patches

Until we support deploying argo with a mechanism that allows overrides, I'm keeping patch files here. These can _add or modify_ things in kubernetes resources, but not necessarily remove them.

To apply a patch, use the `kubectl patch` command:

```
kubectl -n argocd patch configmap argocd-cm --patch "$(cat argocd-configmap-patch.yaml)"
```
