# Terraform configurations

This directory contains (or eventually will contain) the terraform definitions for the infrastructure behind various clingen components.

- `modules/` - Contains reusable terraform modules. Appropriate for shared code between environments
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
