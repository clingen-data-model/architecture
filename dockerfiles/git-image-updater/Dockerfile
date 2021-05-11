FROM gcr.io/cloud-builders/git

RUN apt-get update \
  && apt-get install -y wget \
  && wget https://github.com/mikefarah/yq/releases/download/v4.7.1/yq_linux_amd64 -O /usr/bin/yq \
  && chmod +x /usr/bin/yq \
  && wget https://github.com/cli/cli/releases/download/v1.9.2/gh_1.9.2_linux_amd64.tar.gz -O /tmp/gh-cli.tar.gz \
  && tar -C / -xzf /tmp/gh-cli.tar.gz --strip-components=1 \
  && rm /tmp/gh-cli.tar.gz \
  && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/bin/bash"]
