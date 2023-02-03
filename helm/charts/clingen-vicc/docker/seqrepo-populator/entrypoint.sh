#!/usr/bin/env bash
set -xeuo pipefail

PWD_ORIG=`pwd`

# Set DATA_DIR
if [ -z "$DATA_DIR" ]; then
    echo "Must set DATA_DIR"
    exit 1
fi

seqrepo_zip=seqrepo_2021-01-29.tar.gz
seqrepo_version=2021-01-29

if [ ! -d "${DATA_DIR}/seqrepo" ]; then
    mkdir -p "${DATA_DIR}/seqrepo"
fi
cd "${DATA_DIR}/seqrepo"
if [ ! -d "$seqrepo_version" ]; then
    if [ ! -f "seqrepo/$seqrepo_zip" ]; then
        gcloud storage cp "gs://clingen-dev-gke-internal-static/${seqrepo_zip}" ./
        tar -xzf "$seqrepo_zip" -C ./
        # Make sure the version dir was in the zip
        if [ ! -d "$seqrepo_version" ]; then
            echo "Downloaded $seqrepo_zip but it did not contain $seqrepo_version"
            exit 1
        fi
        rm "$seqrepo_zip"
    fi
fi

cd "$PWD_ORIG"
