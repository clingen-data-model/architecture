# Terraform configurations

This directory contains (or eventually will contain) the terraform definitions for the infrastructure behind various clingen components.

- `modules/` - Contains reusable terraform modules. Appropriate for shared components that are reused or repeated between environments
- `shared/` - Configuration that is defined centrally for all environments. Appropriate for configs that are not necessarily reusable, but try to express identical configurations in all of det,stage, and prod.
- `dev/` - development environment configs
- `stage/` - staging environment configs
- `prod/` - production environment configs

## Tools

Our terraform configuration utilizes two tools: terraform, and terragrunt. Both terraform and terragrunt can be installed via homebrew.

In general, you'll be interacting with terragrunt, which is a thin wrapper around terraform itself. We're primarily using terragrunt to take advantage of its capabilities for templating terraform code that's duplicated in many places. The workflow is typically that you'll run the `terragrunt` command, which will then template out the reusable bits of code, and then it'll invoke the terraform CLI on your behalf. Once terragrunt generates the templated code, you **can** use terraform on its own to apply configurations, but to keep things simple, it's best to just use the terragrunt cli for applying configurations.

Terragrunt supports all the built-in commands that you would typically pass to the terraform utility.

When learning the terraform language and how it works, you should consult the [Terraform Documentation](https://www.terraform.io/docs).

Documentation for the terragrunt CLI can be found here: [Terragrunt CLI Docs](https://terragrunt.gruntwork.io/docs/reference/cli-options/)

## terraform remote state

To ensure that our infrastrucutre state is kept backed-up, and locked to prevent simultaneous executions, the [terraform state](https://www.terraform.io/docs/language/state/index.html) files are kept in GCS buckets. Since I'd like the buckets to exist before terraform can store state in them, the buckets need to be created by hand, rather than managed with terraform. See the [Remote State](https://www.terraform.io/docs/language/settings/backends/gcs.html) docs for more info.

## Inovking terragrunt / terraform

To apply a configuration, cd into the desired env folder, and:

- If it's the first time you've executed terragrunt or terraform, you may need to run `terragrunt init`.
- make the desired changes to the terraform manifests.
- Run a `terragrunt plan` to see the difference between the current configuration, and the actual infrastructure.
- If the plan looks good, run `terragrunt apply` to apply your changes (it will stop and ask you to confirm first). 

## Testing and linting

We're using a tool called tflint to lint the terraform manifests. tflint can be installed with `brew install tflint`, or can be downloaded from: https://github.com/terraform-linters/tflint/releases.

A helper script is included in terraform/linter.sh. To run it, cd into the terraform folder, and run the script.

If you'd like to lint an individual terraform configuration, you need to cd into one of the dev/stage/prod folders, and then run tflint with the -c flag to point at the shared .tflint.hcl config file:

```bash
cd terraform
tflint --init # you can skip this if you've already init'd before
tflint --module -c ../.tflint.hcl # the --module flag tells tflint to recurse referenced modules
```
