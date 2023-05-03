#!/usr/bin/env bash

set -xeuo pipefail

registry_ns=gcr.io/clingen-dev
repo_dir=variation-normalization
repo_name=theferrit32/variation-normalization
repo_commit=queryhandler-concurrent-access-fix
repo=https://github.com/${repo_name}.git


if [ ! -d $repo_dir/.git ]; then
    git clone $repo $repo_dir
    cd $repo_dir
    git fetch --all --tags --prune
    git checkout $repo_commit
    cd ..
    # updated Pipfile
    #cp replacement-Pipfile $repo_dir/Pipfile
    cp replacement-Dockerfile $repo_dir/Dockerfile
fi

image=gcr.io/clingen-dev/variation-normalization:mutex-patch
docker build -t $image $repo_dir
docker push $image
