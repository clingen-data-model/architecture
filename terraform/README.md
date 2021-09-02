# Terraform configurations

This directory contains (or eventually will contain) the terraform definitions for the infrastructure behind various clingen components.

- `modules/` - Contains reusable terraform modules. Appropriate for shared components that are reused or repeated between environments
- `shared/` - Configuration that is defined centrally for all environments. Appropriate for configs that are not necessarily reusable, but try to express identical configurations in all of det,stage, and prod.
- `dev/` - development environment configs
- `stage/` - staging environment configs
- `prod/` - production environment configs

## terraform remote state

To ensure that our infrastrucutre state is kept backed-up, and locked to prevent simultaneous executions, the [terraform state](https://www.terraform.io/docs/language/state/index.html) files are kept in GCS buckets. Since I'd like the buckets to exist before terraform can store state in them, the buckets need to be created by hand, rather than managed with terraform. See the [Remote State](https://www.terraform.io/docs/language/settings/backends/gcs.html) docs for more info.

## Inovking terraform

To apply a configuration, cd into the desired env folder, and:

- If it's the first time you've executed terraform, run `terraform init`.
- make the desired changes to the terraform manifests.
- Run a `terraform plan` to see the difference between the current configuration, and the actual infrastructure.
- If the plan looks good, run `terraform apply` to apply your changes (it will stop and ask you to confirm first). 

## Testing and linting

We're using a tool called tflint to lint the terraform manifests. tflint can be installed with `brew install tflint`, or can be downloaded from: https://github.com/terraform-linters/tflint/releases.

A helper script is included in terraform/linter.sh. To run it, cd into the terraform folder, and run the script.

If you'd like to lint an individual terraform configuration, you need to cd into one of the dev/stage/prod folders, and then run tflint with the -c flag to point at the shared .tflint.hcl config file:

```bash
cd terraform
tflint --init # you can skip this if you've already init'd before
tflint --module -c ../.tflint.hcl # the --module flag tells tflint to recurse referenced modules
```
