#!/usr/bin/env bash

set -xeuo pipefail

registry_ns=gcr.io/clingen-dev
repo=https://github.com/cancervariants/gene-normalization.git
repo_dir=gene-normalization
repo_commit=v0.1.31

if [ ! -d $repo_dir/.git ]; then
    git clone $repo
    cd $repo_dir
    git fetch --all --tags --prune
    git checkout $repo_commit
    cd ..
    cp replacement-Pipfile $repo_dir/Pipfile
fi

git_version () {
    cd $repo_dir
    val=`git rev-parse HEAD`
    cd ..
    echo $val
}

docker build -t ${registry_ns}/cancervariants/gene-normalization:${repo_commit} gene-normalization
docker push ${registry_ns}/cancervariants/gene-normalization:${repo_commit}
