# This image just downloads the seqrepo archive from GCS and unpacks it into a filesystem

FROM google/cloud-sdk:alpine

RUN apk add python3 py3-pip

COPY entrypoint.sh entrypoint.sh

CMD ["bash", "entrypoint.sh"]
