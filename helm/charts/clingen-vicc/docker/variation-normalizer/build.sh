#!/usr/bin/env bash

set -xeuo pipefail

registry_ns=gcr.io/clingen-dev
repo_name=cancervariants/variation-normalization
repo_dir=variation-normalization
repo=https://github.com/${repo_name}.git

# On issue-492 branch
repo_commit=043285a388910b31a1ba522cad51125bec666a29

if [ ! -d $repo_dir/.git ]; then
    git clone $repo $repo_dir
    cd $repo_dir
    git fetch --all --tags --prune
    git checkout $repo_commit
    cd ..
fi

cp replacement-Dockerfile-nginx $repo_dir/Dockerfile
cp start_servers.py $repo_dir/
cp varnorm-nginx-template.conf $repo_dir/
cp requirements.txt $repo_dir/

# cp main_new.py $repo_dir/variation/main.py
# # Add version limit to pydantic
# cp $repo_dir/setup.cfg $repo_dir/setup.cfg.bkp
# sed 's/ pydantic\s*$/ pydantic < 2.0.0/g' $repo_dir/setup.cfg.bkp > $repo_dir/setup.cfg
# #sed 's/ga4gh.vrsatile.pydantic >= 0.1.0.dev7/ga4gh.vrsatile.pydantic == 0.1.0.dev7/g' $repo_dir/setup.cfg.bkp2 > $repo_dir/setup.cfg
# # Add version limit to cool-seq-tool
# cp $repo_dir/setup.cfg $repo_dir/setup.cfg.bkp2
# sed 's/cool-seq-tool >= 0.1.13/cool-seq-tool == 0.1.13/g' $repo_dir/setup.cfg.bkp2 > $repo_dir/setup.cfg


docker build -t ${registry_ns}/${repo_name}:${repo_commit} $repo_dir
docker push ${registry_ns}/${repo_name}:${repo_commit}
