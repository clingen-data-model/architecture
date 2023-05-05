# Populate seqrepo volume
`
docker volume create seqrepo
`

## Use the seqrepo populator image to populate it. Need to pass in a gcloud config directory that is authenticated

`
docker run -it --rm -v seqrepo:/usr/local/share/seqrepo -e DATA_DIR=/usr/local/share -e CLOUDSDK_CONFIG=/config/gcloud -v ~/.config/gcloud:/config/gcloud gcr.io/clingen-dev/vicc-seqrepo-populator:2021-01-29
`

## Alternatively, remove the config environment variable and the gcloud volume and authenticate interactively
`
docker run -it --rm -v seqrepo:/usr/local/share/seqrepo -e DATA_DIR=/usr/local/share gcr.io/clingen-dev/vicc-seqrepo-populator:2021-01-29
`

// Then in the container:
`gcloud auth login` (will give login url and prompt for auth code that can be copied from the browser)
// Run the container as normal now with authenticated gcloud library
`bash entrypoint.sh`

# Run dynamodb

`
docker run -it --rm -v dynamodb:/data -e DATA_DIR=/data -p 8000:8000 gcr.io/clingen-dev/vicc-dynamodb:latest
`

# Gene Normalizer
`
docker run -it --rm -v $(pwd)/credentials:/root/.aws/credentials -p 8001:8001 gcr.io/clingen-dev/cancervariants/gene-normalization:c64a53fe305e9ec3eac51d9988385a5bc0ef3ac0 pipenv run uvicorn gene.main:app --port 8001 --host 0.0.0.0
`

# UTA
`
docker run -it --rm -e UTA_VERSION=uta_20210129 -e UTA_ADMIN_PASSWORD=uta_pw -e POSTGRES_PASSWORD=pg_pw -p 5432:5432 gcr.io/clingen-dev/uta:uta_20210129
`

# Variation Normalizer
## Create a dummy credentials file to make boto library (for accessing dummy dynamodb) happy
```
echo "[default]
aws_access_key_id = asdf
aws_secret_access_key = asdf" > credentials
```

## Variation Normalizer with Uvicorn and a single worker
`
docker run -it --rm -v seqrepo:/usr/local/share/seqrepo -v $(pwd)/credentials:/root/.aws/credentials -e SEQREPO_ROOT_DIR=/usr/local/share/seqrepo/2021-01-29 -e GENE_NORM_DB_URL='http://docker.for.mac.host.internal:8000' -e UTA_DB_URL="postgresql://uta_admin:uta_pw@docker.for.mac.host.internal:5432/uta/uta_20210129" -p 8002:80 gcr.io/clingen-dev/variation-normalization:mutex-patch bash -c "pipenv run uvicorn variation.main:app --workers 1 --port 80 --host 0.0.0.0"
`

## Variation Normalizer with Gunicorn and multiple workers and periodic worker restart

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



# Removing pipenv from Variation Normalizer

There's already a setup.cfg, so we can mostly just use that.

- Update variation normalizer docker image base to python:3.9
- Remove pipenv lock/sync, replace with `pip install .`
- Add `--pre` to pip install in order to get `ga4gh.vrsatile.pydantic` pre-releases from pypi
- Change `echo` and `pipenv run` initialization step to just `python -c 'import cool_seq_tool'`
- Change `pipenv run gunicorn` to just `gunicorn`


`
docker run -it --rm -v seqrepo:/usr/local/share/seqrepo -v $(pwd)/credentials:/root/.aws/credentials -e DATA_DIR=/usr/local/share -e SEQREPO_ROOT_DIR=/usr/local/share/seqrepo/2021-01-29 -e GENE_NORM_DB_URL='http://docker.for.mac.host.internal:8000' -e UTA_DB_URL="postgresql://uta_admin:uta_pw@docker.for.mac.host.internal:5432/uta/uta_20210129" -p 8002:80 gcr.io/clingen-dev/variation-normalization:mutex-patch bash -c 'python -c "import cool_seq_tool" && gunicorn -w 4 --bind 0.0.0.0:80 --max-requests 10000 -k uvicorn.workers.UvicornWorker variation.main:app'
`

Unfortunately when running in Gunicorn, the Uvicorn worker cannot figure out to run with websocket support, despite the necessary pip packages being installed.

```
[2023-05-03 23:20:06 +0000] [870] [WARNING] Unsupported upgrade request.
[2023-05-03 23:20:06 +0000] [870] [WARNING] No supported WebSocket library detected. Please use "pip install 'uvicorn[standard]'", or install 'websockets' or 'wsproto' manually.
```

Uvicorn also does not support http2. But there is a different runner called hypercorn that does, and also seems to be able to figure out how to run.

daphne -b 0.0.0.0 -p 80 variation.main:app
hypercorn -w 2 --bind 0.0.0.0:80 -k uvloop variation.main:app



# Hypercorn
`
docker run -it --rm -v seqrepo:/usr/local/share/seqrepo -v $(pwd)/credentials:/root/.aws/credentials -e DATA_DIR=/usr/local/share -e SEQREPO_ROOT_DIR=/usr/local/share/seqrepo/2021-01-29 -e GENE_NORM_DB_URL='http://docker.for.mac.host.internal:8000' -e UTA_DB_URL="postgresql://uta_admin:uta_pw@docker.for.mac.host.internal:5432/uta/uta_20210129" -p 8002:80 gcr.io/clingen-dev/variation-normalization:mutex-patch bash -c 'python -c "import cool_seq_tool" && hypercorn -w 2 --bind 0.0.0.0:80 -k uvloop variation.main:app'
`


# Running out of a local venv

Assumes:
- dynamo is available on port 8000
- seqrepo is populated in a local dir
- uta postgres is running on port 5432

SEQREPO_ROOT_DIR=/Users/kferrite/dev/biocommons.seqrepo/seqrepo/2021-01-29 GENE_NORM_DB_URL='http://localhost:8000' UTA_DB_URL="postgresql://uta_admin:uta_pw@localhost:5432/uta/uta_20210129" bash -c 'python -c "import cool_seq_tool" && uvicorn variation.main:app --workers 4 --port 8002 --host 0.0.0.0'
