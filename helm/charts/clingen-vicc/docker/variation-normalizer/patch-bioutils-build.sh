#!/bin/bash
# Clone bioutils so we can patch to fix build issue
mkdir src
cd src
git clone git+https://github.com/biocommons/bioutils.git@0.5.8.pre1
cd bioutils*
sed 's/dynamic = \["version"\]/dynamic = ["version","dependencies","optional-dependencies"]/' < pyproject.toml > pyproject.toml.fixed
mv pyproject.toml.fixed pyproject.toml
cd ../..
pip install -e src/bioutils
