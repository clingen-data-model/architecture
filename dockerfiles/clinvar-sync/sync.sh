#!/bin/bash

set -euo pipefail

# wait for google cloud to wake up...
sleep 10

# associate the current shell with the service account
gcloud auth activate-service-account clinvar-bq-updater@clingen-stage.iam.gserviceaccount.com --key-file=/var/secrets/google/key.json --project=clingen-stage

sleep 5

GTOKEN=`gcloud auth print-access-token --quiet`

# get the most recent dataset name that exists in the clingen-stage project
max_ds=`eval "bq query --use_legacy_sql=false --quiet --format=csv \"SELECT MAX(schema_name) FROM clingen-stage.INFORMATION_SCHEMA.SCHEMATA WHERE REGEXP_CONTAINS(schema_name, r'clinvar_[0-9]{4}_[0-9]{2}_[0-9]{2}')\" | awk '{if(NR>1)print}'"`

# get any datasets and their ids that are greater than the most recent existing one
x=`curl -s -X GET "https://data.terra.bio/api/repository/v1/snapshots?direction=asc&filter=clinvar&limit=10000&offset=0&sort=name" -H "accept: application/json" -H "authorization: Bearer $GTOKEN"| jq -r '.items[] | select(.name > "'${max_ds}'") | "\(.id) \(.name)"'`

if [ -z "$x" ]
then
      echo "No new datasets to process."
      exit 0
fi

# loop through them, get the data project info and create the new datastset in clinge-stage
echo "$x" | while read id name ; do
    dataProject=`curl -s -X GET "https://data.terra.bio/api/repository/v1/snapshots/$id?include=DATA_PROJECT" -H "accept: application/json" -H "authorization: Bearer $GTOKEN" | jq .dataProject | tr -d '"'`
    echo "bq query --use_legacy_sql=false  'CALL \`clingen-stage.clinvar_qa.create_clinvar_dataset\`("\""${dataProject}.${name}"\"", "\""clingen-stage.${name}"\"")'"
    # eval "bq query --use_legacy_sql=false  'CALL \`clingen-stage.clinvar_qa.create_clinvar_dataset\`("\""${dataProject}.${name}"\"", "\""clingen-stage.${name}"\"")'"
    echo "Created view clingen-stage.${name} based on ${dataProject}.${name}"
done

echo "complete!"
