FROM ubuntu:20.04

RUN apt-get update \
  && apt-get install --no-install-recommends -y \
     wget \
     ca-certificates \
     unzip \
  && wget -q https://releases.hashicorp.com/terraform/1.0.5/terraform_1.0.5_linux_amd64.zip -O /tmp/terraform.zip \
  && unzip /tmp/terraform.zip -d /usr/local/bin \
  && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/bin/bash"]
