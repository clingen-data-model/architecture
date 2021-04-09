# Umbrella helm chart for deploying the clingen argocd instance

This helm chart pulls in the upstream argo-cd helm chart from the [argo-helm repository](https://argoproj.github.io/argo-helm). The idea, is that we provide any resources which are required on our end, in the templates directory, and then pass in the variable values that we want into the argo-cd chart using the values.yaml file.

## Installing argo in clingen

To start, set your kubeconfig context to the desired k8s cluster, and then create the argocd namespace

```
kubectl create namespace argocd
```

Then, download our dependencies:

```
cd <repo>/helm/charts/clingen-argocd
helm dependency build .
```

Then, install the chart into the argocd namespace:

```
cd <repo>/helm
helm install -n argocd clingen-argocd charts/clingen-argocd
```

## Manual configuration

### Github authentication

To configure Github SSO, we need to edit a secret that's created by argocd, which can only be done after the chart is installed.

Generate an OAuth token for the argocd application in the clingen-data-model github organization settings, and copy the "Client Secret"

base64 encode it, and then add it to a key called `dex.github.clientSecret` in the `data` field of the argocd-secret secret in k8s:

```
echo -n "<client secret token>" | base64
kubectl edit -n argocd argocd-secret
```

### rotate the admin password

The installation generates a password for the admin user. It should be rotated to a known value after installation.

```
# The current admin password is stored in a secret called argocd-initial-admin-secret. Retrieve and decode the password:
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -D

# Set up port forwarding
kubectl port-forward service/clingen-argocd-server -n argocd 8080:443

# Log in and change password
argocd login localhost:8080 --username admin
argocd account update-password

# Be sure to set the password and store it in the GCP secret manager
```
