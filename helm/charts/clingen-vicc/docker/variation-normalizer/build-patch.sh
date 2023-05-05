#!/usr/bin/env bash

set -xeuo pipefail

registry_ns=gcr.io/clingen-dev
repo_dir=variation-normalization
repo_name=theferrit32/variation-normalization
# bioutils-large-seqs branches from queryhandler-concurrent-access-fix
# Includes queryhandler mutex and Dockerfile that uses fork of bioutils
repo_commit=bioutils-large-seqs
repo=https://github.com/${repo_name}.git


if [ ! -d $repo_dir/.git ]; then
    git clone $repo $repo_dir
    cd $repo_dir
    git fetch --all --tags --prune
    git checkout $repo_commit
    cd ..
fi

cp replacement-Dockerfile $repo_dir/Dockerfile
# main-patch-queue has been incorporated into theferrit32/bioutils-large-seqs
#cp main-patch-queue.py $repo_dir/variation/main.py

image=gcr.io/clingen-dev/variation-normalization:clingen-updates
docker build -t $image $repo_dir
docker push $image
