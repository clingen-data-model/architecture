# clingen-genegraph

This chart is used for deploying variations of the genegraph application. Values for the different instances of genegraph are kept in this repository's `helm/values` directory.

## Manual deployment instructions

We'll mostly be relying on Argocd to deploy these charts, but there are cases (like a development environment) where you might want to manually deploy genegraph.

### Rendering templates

Helm generally differentiates between instances of genegraph by providing each instance with a name. Rendering the manifests for an instance typically takes the form of:

`helm template <instance-name> charts/clingen-genegraph -f <path to input values>`

Where instance name is the name of the specific genegraph installation you're trying to deploy or install. E.g. "genegraph", "genegraph-clinvar", or "genegraph-gvdev". It is important to pick a unique instance name when deploying a new configuration. Using an existing name will upgrade or replace that instance if it's already running in the cluster.

To render a genegraph instance template, you can use the `helm template` command. For example, to show the manifests for the development genegraph instance, cd to the top-level helm folder in this repository and run `helm template genegraph charts/clingen-genegraph -f values/genegraph/values-dev.yaml`.

To render the development clinvar instance, simply switch the input file passed with `-f`:

`helm template genegraph-clinvar charts/clingen-genegraph -f values/genegraph-clinvar/values-dev.yaml`

### Deploying the chart

There's a few options for actually installing the chart. Before doing these, ensure that your `kubectl` cli is pointing at the right kubernetes cluster.

1. The output of the `helm template` command can be piped to `kubectl apply` for deployment (and `kubectl delete` for uninstalling). This is how Argocd works behind the scenes.
2. You can optionally use the helm cli to install the application: `helm install --upgrade genegraph-clinvar charts/clingen-genegraph -f <path to values yaml>`

There's some subtle differences between the two. The helm install method integrates with some of helm's lifecycle features (apps show up in `helm ls`, and can be uninstalled with `helm uninstall`, and `helm rollback` can be used.)

## Adding a new genegraph instance

If you want to deploy a new configuration of genegraph, you can do so by providing a new instance name and a new set of values to helm. The quickest way is likely to copy a values file from an existing deployment that looks most similar, then change the variables that need to be modified. Once you've got your new values inputs, you can deploy as described above. (e.g. `helm template genegraph-newinstance charts/clingen-genegraph -f values/genegraph-newinstance/values-dev.yaml) | kubectl apply -f -`
