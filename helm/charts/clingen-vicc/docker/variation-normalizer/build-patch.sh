#!/usr/bin/env bash

set -xeuo pipefail

registry_ns=gcr.io/clingen-dev
repo_dir=variation-normalization
repo_name=cancervariants/variation-normalization
repo_commit=0b299fe4dc8d4732d62a23bdd215ec13022130d0
repo=https://github.com/${repo_name}.git

if [ ! -d $repo_dir/.git ]; then
    git clone $repo $repo_dir
    cd $repo_dir
    git fetch --all --tags --prune
    git checkout $repo_commit
    cd ..
fi

cp start_servers.py $repo_dir/
cp varnorm-nginx-template.conf $repo_dir/
cp main_new.py $repo_dir/variation/main.py

# Add version limit to pydantic
cp $repo_dir/setup.cfg $repo_dir/setup.cfg.bkp
sed 's/ pydantic\s*$/ pydantic < 2.0.0/g' $repo_dir/setup.cfg.bkp > $repo_dir/setup.cfg

image=gcr.io/clingen-dev/variation-normalization:clingen-updates
docker build -t $image -f replacement-Dockerfile-nginx $repo_dir
docker push $image
