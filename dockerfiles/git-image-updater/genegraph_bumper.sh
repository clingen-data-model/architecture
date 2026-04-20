#!/usr/bin/env bash

# invocation: ./genegraph_bumper.sh genegraph abcdef1 "./helm/values/genegraph/values-stage.yaml,./helm/values/genegraph/values-prod.yaml"
set -euo pipefail

GENEGRAPH_DEPLOYMENT=$1
COMMIT_SHA=$2
UPDATE_FILES_LIST=$3
IFS="," read -ra UPDATE_FILES <<< "$UPDATE_FILES_LIST"
SHORT_SHA=${COMMIT_SHA:0:7}

# retrieve the architecture repo and check out a branch
git clone https://clingen-ci:$$GITHUB_TOKEN@github.com/clingen-data-model/architecture
cd architecture
git checkout -b image-update-$GENEGRAPH_DEPLOYMENT-$SHORT_SHA # TODO: this needs to be more specific

# generate a datestamp
date "+%Y-%m-%dT%H%M" > /tmp/DATETIME.txt

# for every file in UPDATE_FILES, update the image tag and data version
for filename in "${UPDATE_FILES[@]}"
do
    /usr/bin/yq eval -i ".genegraph_docker_image_tag = \"$COMMIT_SHA\"" $filename
    /usr/bin/yq eval -i ".genegraph_data_version = \"$(tr -d '\n' < /tmp/DATETIME.txt)\"" $filename
done

# commit the changes
git add -u
git -c user.name="Clingen CI Automation" -c user.email="clingendevs@broadinstitute.org" commit -m "bumping docker image for ${GENEGRAPH_DEPLOYMENT}"
git push origin image-update-$GENEGRAPH_DEPLOYMENT-$SHORT_SHA
gh pr create --fill -l automation
