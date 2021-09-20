# clinvar-streams Helm Chart

To render the clinvar-combiner manifest for the dev environment:

`helm template clinvar-combiner-dev charts/clingen-clinvar-streams -f values/clinvar-streams/clinvar-combiner/values-dev.yaml`

To install it (or upgrade existing installation)

`helm upgrade --install clinvar-combiner-dev charts/clingen-clinvar-streams -f values/clinvar-streams/clinvar-combiner/values-dev.yaml`
