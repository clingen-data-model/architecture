# Argo ApplicationSets

[ApplicationSets](https://argo-cd.readthedocs.io/en/stable/user-guide/application-set/) are Argo's way of reducing duplication when you have (nearly) identical applications to install on all of your clusters. AppSets are most useful for deploying 3rd party depencies that all of our GKE clusters depend on. This directory contains the ApplicationSet manifests that we use on the cluster.

## External Secrets

The External Secrets Operator is a tool for synchronizing secrets from many available secret providers (we use the google cloud Secret Manager in our case) to secrets within the kubernetes cluster. After installing the helm chart, two components become available for configuration within our cluster: SecretStore, and ExternalSecret.

A SecretStore configures the operator for retrieving secrets from a source. An ExternalSecret is a mapping that describes what secret you'd like to sync, the target kubernetes secret to sync it to, and which SecretStore to use to access it.

In our cluster, we use a ClusterSecretStore, which is a SecretStore that is available for ExternalSecrets in all kubernetes namespaces to use. In general, the ClusterSecretStore is most useful to us, but a SecretStore might be used in a scenario where you want to use a different secret backend (perhaps a different project's GCP Secret Manager) for syncing secrets to a single kubernetes namespace.

### Summary
- Site: https://external-secrets.io/
- Repository (helm chart is under deploy/charts/external-secrets): https://github.com/external-secrets/external-secrets
- Deployment: on all of our GKE clusters, in the external-secrets namespace.

### Configuration

The helm chart can be installed (via our Argo AppSet) without any special customization. Once installed, we need to create a secret that the ClusterSecretStore can use to access the GCP secret manager. This involves retrieving the external-secrets service account key that is generated in terraform, and creating a kubernetes secret with it:

```bash
# Download the service account JSON key from the GCP console, save to /tmp/gcp-creds.json, and then create the k8s secret:
kubectl -n external-secrets create secret generic gcp-creds --from-file=gcp-creds.json=/tmp/gcp-creds.json
```

This needs to be done manually when provisioning a new cluster, since the secret manager can't start syncing secrets until it has the credentials to do so. In the future, GKE clusters should be configured with [Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity), which will make this step unnecessary.
