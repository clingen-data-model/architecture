#!/usr/bin/env bash

set -xeuo pipefail

registry_ns=gcr.io/clingen-dev
repo_name=cancervariants/variation-normalization
repo_dir=variation-normalization
repo=https://github.com/${repo_name}.git
# On staging branch
# repo_commit=1e9c53dbec4f3f0ec907cae94d9d295534b4c424
# repo_commit=0b299fe4dc8d4732d62a23bdd215ec13022130d0

# On issue-492 branch
repo_commit=58b9bc33073478bcf572cad34be896fea536dedd

if [ ! -d $repo_dir/.git ]; then
    git clone $repo $repo_dir
    cd $repo_dir
    git fetch --all --tags --prune
    git checkout $repo_commit
    cd ..
    # staging branch updated Pipfile
    cp replacement-Dockerfile $repo_dir/Dockerfile
fi

cp replacement-Dockerfile $repo_dir/Dockerfile
cp main_new.py $repo_dir/variation/main.py

# Add version limit to pydantic
cp $repo_dir/setup.cfg $repo_dir/setup.cfg.bkp
sed 's/ pydantic\s*$/ pydantic < 2.0.0/g' $repo_dir/setup.cfg.bkp > $repo_dir/setup.cfg

#sed 's/ga4gh.vrsatile.pydantic >= 0.1.0.dev7/ga4gh.vrsatile.pydantic == 0.1.0.dev7/g' $repo_dir/setup.cfg.bkp2 > $repo_dir/setup.cfg

# Add version limit to cool-seq-tool
cp $repo_dir/setup.cfg $repo_dir/setup.cfg.bkp2
sed 's/cool-seq-tool >= 0.1.13/cool-seq-tool == 0.1.13/g' $repo_dir/setup.cfg.bkp2 > $repo_dir/setup.cfg


docker build -t ${registry_ns}/${repo_name}:${repo_commit} $repo_dir
docker push ${registry_ns}/${repo_name}:${repo_commit}
