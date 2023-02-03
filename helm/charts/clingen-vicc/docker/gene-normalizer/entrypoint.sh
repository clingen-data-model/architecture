#!/bin/env bash
set -xeuo pipefail

db_zip=shared-local-instance-20230111-main.db.zip
db_name=shared-local-instance.db

if [ ! -f "$db_name" ]; then
    gcloud storage cp gs://clingen-dev-gke-internal-static/${db_zip} ./
    unzip $db_zip
fi

seqrepo_zip=seqrepo_2021-01-29.tar.gz
seqrepo_version=2021-01-29
if [ ! -d seqrepo ]; then mkdir seqrepo; fi
if [ ! -d $seqrepo_version ]; then
    if [ ! -f seqrepo/$seqrepo_zip ]; then
        gcloud storage cp gs://clingen-dev-gke-internal-static/${seqrepo_zip} ./seqrepo/
        tar -xzf $seqrepo_zip -C ./seqrepo/
    fi
fi

# Used by seqrepo
export SEQREPO_ROOT_DIR=`pwd`/seqrepo

# Used by gene-normalizer
export SEQREPO_DATA_PATH=$SEQREPO_ROOT_DIR/$seqrepo_version

echo "starting dynamo jar"
java -Djava.library.path=./DynamoDBLocal_lib -jar DynamoDBLocal.jar -sharedDb
