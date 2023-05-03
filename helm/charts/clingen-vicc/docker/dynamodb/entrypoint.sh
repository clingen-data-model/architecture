#!/bin/env bash
set -xeuo pipefail

# Set DATA_DIR
if [ -z "$DATA_DIR" ]; then
    echo "Must set DATA_DIR"
    exit 1
fi

mkdir -p "$DATA_DIR"

db_zip=shared-local-instance-20230111-main.db.zip
db_name=shared-local-instance.db

if [ ! -f "$DATA_DIR/$db_name" ]; then
    cd "$DATA_DIR"
    gcloud storage cp "gs://clingen-dev-gke-internal-static/${db_zip}" ./
    unzip "$db_zip"
    if [ ! -f "$db_name" ]; then
        echo "Downloaded $db_zip but it did not contain $db_name"
        ls
        exit 1
    fi
    cd ..
fi

# Dynamodb stuff is in /app but that data is in DATA_DIR
ln -sf "${DATA_DIR}/${db_name}" /app/${db_name}

cd /app

echo "starting dynamodb jar"
java -Djava.library.path=./DynamoDBLocal_lib -jar DynamoDBLocal.jar -sharedDb
echo "dynamodb jar exited"
