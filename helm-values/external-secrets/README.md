# Helm Values and bootstrapping External Secrets

Since External Secrets needs to be deployable without another secrets process in place, we need to start by manually creating the secret containing the GCP creds. NOTE: We eventually want to switch the GKE cluster to using workload identity, after which this won't be necessary.

## Create a namespace and secret

The serivce account key is stored in the GCP secret manager. Start by retrieving the key from there, and saving it to your filesystem.

Now, deploy the secret into a namespace called external-secrets.

```
kubectl create namespace external-secrets
kubectl -n external-secrets create secret generic gcp-creds --from-file=gcp-creds.json=/tmp/gcp-creds.json
```

Remove the local copy of the credential key when you're done.

## Deploying external secrets

We're going to use helm to deploy the external secrets application, and pass in our override values here.

```
# If it's not there already, add the external-secrets helm repo to our helm installation
helm repo add external-secrets https://external-secrets.github.io/kubernetes-external-secrets/
```

```
# now, install external-secrets and pass in your values overrides with -f
helm install -n external-secrets external-secrets external-secrets/kubernetes-external-secrets -f externalsecrets-values.yaml
```
