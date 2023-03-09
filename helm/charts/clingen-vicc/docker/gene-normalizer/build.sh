#!/usr/bin/env bash

set -xeuo pipefail

registry_ns=gcr.io/clingen-dev
repo_name=cancervariants/gene-normalization
repo_dir=gene-normalization
repo=https://github.com/${repo_name}.git
# On staging branch
repo_commit=c64a53fe305e9ec3eac51d9988385a5bc0ef3ac0

if [ ! -d $repo_dir/.git ]; then
    git clone $repo
    cd $repo_dir
    git fetch --all --tags --prune
    git checkout $repo_commit
    cd ..
fi

docker build -t ${registry_ns}/${repo_name}:${repo_commit} ${repo_dir}
docker push ${registry_ns}/${repo_name}:${repo_commit}
