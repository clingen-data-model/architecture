FROM gcr.io/google.com/cloudsdktool/cloud-sdk:362.0.0

RUN apt-get update \
    && apt-get -y install jq --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

COPY sync.sh /usr/local/bin
