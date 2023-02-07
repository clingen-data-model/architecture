FROM eclipse-temurin:17

#RUN apt update && apt install -y #curl

# Add local sqlite-backed version of dynamodb
RUN curl -O https://s3.us-west-2.amazonaws.com/dynamodb-local/dynamodb_local_latest.tar.gz
RUN tar -xzf dynamodb_local_latest.tar.gz

# Add google debian apt repo and install gcloud
RUN apt-get update \
    && apt-get install -y apt-transport-https ca-certificates gnupg \
    && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - \
    && apt-get update && apt-get install -y --no-install-recommends google-cloud-cli

RUN apt-get install -y zip


COPY entrypoint.sh entrypoint.sh
CMD ["bash", "entrypoint.sh"]
