#!/usr/bin/env bash

set -xeuo pipefail

registry_ns=gcr.io/clingen-dev
repo_name=cancervariants/variation-normalization
repo_dir=variation-normalization
repo=https://github.com/${repo_name}.git
# On staging branch
repo_commit=1e9c53dbec4f3f0ec907cae94d9d295534b4c424

if [ ! -d $repo_dir/.git ]; then
    git clone $repo $repo_dir
    cd $repo_dir
    git fetch --all --tags --prune
    git checkout $repo_commit
    cd ..
    # staging branch updated Pipfile
    cp replacement-Dockerfile $repo_dir/Dockerfile
fi

docker build -t ${registry_ns}/${repo_name}:${repo_commit} $repo_dir
docker push ${registry_ns}/${repo_name}:${repo_commit}
