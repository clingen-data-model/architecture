# Populate seqrepo volume
docker volume create seqrepo

## Use the seqrepo populator image to populate it. Need to pass in a gcloud config directory that is authenticated
docker run -it --rm -v seqrepo2:/usr/local/share/seqrepo -e DATA_DIR=/usr/local/share -e CLOUDSDK_CONFIG=/config/gcloud -v ~/.config/gcloud:/config/gcloud gcr.io/clingen-dev/vicc-seqrepo-populator:2021-01-29
## Alternatively, remove the config environment variable and the gcloud volume and authenticate interactively
docker run -it --rm -v seqrepo2:/usr/local/share/seqrepo -e DATA_DIR=/usr/local/share gcr.io/clingen-dev/vicc-seqrepo-populator:2021-01-29
// Then in the container:
gcloud auth login (will give login url and prompt for auth code that can be copied from the browser)
// Run the container as normal now with authenticated gcloud library
bash entrypoint.sh

# Run dynamodb
docker run -it --rm -v dynamodb:/data -e DATA_DIR=/data -p 8000:8000 gcr.io/clingen-dev/vicc-dynamodb:latest bash entrypoint.sh

# Gene Normalizer
# Uses docker-for-mac localhost hostname
docker run -it --rm -v $(pwd)/credentials:/root/.aws/credentials --net host -p 8001:8001 gcr.io/clingen-dev/cancervariants/gene-normalization:c64a53fe305e9ec3eac51d9988385a5bc0ef3ac0 pipenv run uvicorn gene.main:app --port 8001 --host 0.0.0.0

# UTA
docker run -it --rm -e UTA_VERSION=uta_20210129 -e UTA_ADMIN_PASSWORD=uta_pw -e POSTGRES_PASSWORD=pg_pw -p 5432:5432 gcr.io/clingen-dev/uta:uta_20210129

# Variation Normalizer
## Create a dummy credentials file to make boto library (for accessing dummy dynamodb) happy
echo "[default]
aws_access_key_id = asdf
aws_secret_access_key = asdf" > credentials

## Variation Normalizer with a single worker
docker run -it --rm -v seqrepo:/usr/local/share/seqrepo -v $(pwd)/credentials:/root/.aws/credentials -e DATA_DIR=/usr/local/share -e SEQREPO_ROOT_DIR=/usr/local/share/seqrepo/2021-01-29 -e GENE_NORM_DB_URL='http://docker.for.mac.host.internal:8000' -e UTA_DB_URL="postgresql://uta_admin:uta_pw@docker.for.mac.host.internal:5432/uta/uta_20210129" -p 8002:80 gcr.io/clingen-dev/variation-normalization:mutex-patch bash -c "pipenv run uvicorn variation.main:app --workers 1 --limit-max-requests 1000 --port 80 --host 0.0.0.0"

## Variation Normalizer with multiple gunicorn workers

Originally this wasn't working because an imported library does some stateful inialization on the filesystem that creates issues when multiple uvicorn/gunicorn workers (or just multiple python processes in general) import the library at the same time. But it looks like the init code doesn't run again if the resulting files are already there, so we can get around this by running a trivial initialization of the library before starting our gunicorn server.

`
docker run -it --rm -v seqrepo:/usr/local/share/seqrepo -v $(pwd)/credentials:/root/.aws/credentials -e DATA_DIR=/usr/local/share -e SEQREPO_ROOT_DIR=/usr/local/share/seqrepo/2021-01-29 -e GENE_NORM_DB_URL='http://docker.for.mac.host.internal:8000' -e UTA_DB_URL="postgresql://uta_admin:uta_pw@docker.for.mac.host.internal:5432/uta/uta_20210129" -p 8002:80 gcr.io/clingen-dev/variation-normalization:mutex-patch bash -c 'echo "import cool_seq_tool" > init.py && pipenv run python init.py && pipenv run gunicorn -w 4 --bind 0.0.0.0:80 --max-requests 10000 -k uvicorn.workers.UvicornWorker variation.main:app'
`

This is a combined final docker command for the components below.

### old uvicorn command
`
pipenv run uvicorn variation.main:app --workers 1 --limit-max-requests 1000 --port 80 --host 0.0.0.0
`

### new gunicorn command
`
pipenv run gunicorn -w 1 --bind 0.0.0.0:80 -k uvicorn.workers.UvicornWorker variation.main:app
`
### run the cool-seq-tool stateful init
`
echo "import cool_seq_tool" > init.py && pipenv run python init.py
`
### limiting apparent memory growth / resource leaks

https://docs.gunicorn.org/en/stable/settings.html#max-requests

Growth I observed was slow, and there is significant startup overhead, so a high limit is both desirable and *probably* acceptable.

`gunicorn --max-requests 10000`
