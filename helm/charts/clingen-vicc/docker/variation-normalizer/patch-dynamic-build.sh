#!/usr/bin/env bash

set -xeu

# Clone bioutils so we can patch to fix build issue
mkdir src
# # git clone https://github.com/biocommons/bioutils.git --branch 0.5.8.pre1 src/bioutils
# git clone https://github.com/biocommons/bioutils.git src/bioutils
# cd src/bioutils
# sed 's/dynamic = \["version"\]/dynamic = ["version","optional-dependencies"]/' < pyproject.toml > pyproject.toml.fixed
# mv pyproject.toml.fixed pyproject.toml
# cd ../..
# pip install -e src/bioutils

# now do the same for biocommons.seqrepo
git clone https://github.com/biocommons/biocommons.seqrepo.git src/biocommons.seqrepo
cd src/biocommons.seqrepo
sed 's/dynamic = \["version"\]/dynamic = ["version", "dependencies", "optional-dependencies"]/' < pyproject.toml > pyproject.toml.fixed
mv pyproject.toml.fixed pyproject.toml
cd ../..
pip install -e src/biocommons.seqrepo
