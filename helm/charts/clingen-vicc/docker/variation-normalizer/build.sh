#!/usr/bin/env bash

set -xeuo pipefail

registry_ns=gcr.io/clingen-dev
repo_name=cancervariants/variation-normalization
repo_dir=variation-normalization
repo=https://github.com/${repo_name}.git
repo_commit=5e87d846231b1e8d1e06b3cd811de6e170b5bb73

if [ ! -d $repo_dir/.git ]; then
    git clone $repo $repo_dir
    cd $repo_dir
    git fetch --all --tags --prune
    git checkout $repo_commit
    cd ..
    cp replacement-Pipfile $repo_dir/Pipfile
    cp replacement-Dockerfile $repo_dir/Dockerfile
fi

docker build -t ${registry_ns}/${repo_name}:${repo_commit} $repo_dir
docker push ${registry_ns}/${repo_name}:${repo_commit}
