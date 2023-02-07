# FROM eclipse-temurin:17

# RUN curl -O "https://s3-us-west-2.amazonaws.com/dynamodb-local/dynamodb_local_latest.tar.gz" \
#     && tar -xvzf dynamodb_local_latest.tar.gz \
#     && rm dynamodb_local_latest.tar.gz


FROM eclipse-temurin:17

WORKDIR /app

RUN curl -O https://s3.us-west-2.amazonaws.com/dynamodb-local/dynamodb_local_latest.tar.gz \
    && tar -xzf dynamodb_local_latest.tar.gz \
    && rm dynamodb_local_latest.tar.gz

# Add google debian apt repo
RUN apt-get update \
    && apt-get install -y apt-transport-https ca-certificates gnupg \
    && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - \
    && apt-get update && apt-get install -y --no-install-recommends google-cloud-cli

RUN apt-get install -y zip

COPY entrypoint.sh /app/entrypoint.sh
CMD ["bash", "entrypoint.sh"]
