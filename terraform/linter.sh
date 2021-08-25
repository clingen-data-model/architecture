#!/usr/bin/env bash

set -euo pipefail

for i in dev stage prod; do
    pushd $i
    terraform init -backend=false
    tflint --module -c ../.tflint.hcl
    popd
done
