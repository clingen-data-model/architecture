#!/usr/bin/env bash

set -euo pipefail

for i in dev stage prod; do
    tflint --init
    pushd $i
    terraform get
    tflint --loglevel=info --no-color --module -c ../.tflint.hcl
    popd
done
