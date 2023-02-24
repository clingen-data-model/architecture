
export UTA_VERSION=uta_20210129

docker build -t gcr.io/clingen-dev/uta:${UTA_VERSION} .
docker push gcr.io/clingen-dev/uta:${UTA_VERSION}
