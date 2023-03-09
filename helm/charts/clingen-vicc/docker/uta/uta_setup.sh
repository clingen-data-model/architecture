#!/bin/bash

set -xeo pipefail

if [ -z "$UTA_VERSION" ]; then
    export UTA_VERSION=uta_20210129
fi

if [ -z "$UTA_ADMIN_PASSWORD" ]; then
    echo "Must provide nonempty env var UTA_ADMIN_PASSWORD"
    exit 1
fi

initialized_file="/var/lib/postgresql/data/initialized.txt"
if [ ! -f "$initialized_file" ]; then
    createuser -U postgres uta_admin
    createuser -U postgres anonymous
    createdb -U postgres -O uta_admin uta
    psql -U postgres -c "ALTER USER uta_admin WITH PASSWORD '$UTA_ADMIN_PASSWORD'"

    curl -s "http://dl.biocommons.org/uta/${UTA_VERSION}.pgd.gz" \
        | gzip -cdq  \
        | grep -v "^REFRESH MATERIALIZED VIEW" \
        | psql -U uta_admin -d uta --echo-errors --single-transaction -v ON_ERROR_STOP=1
        #| psql -h localhost -U uta_admin --echo-errors --single-transaction -v ON_ERROR_STOP=1 -d uta -p 5432
fi

echo `date -u +"%Y-%m-%dT%H:%M:%S%z"` > "$initialized_file"
