FROM ubuntu:20.04

# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
     wget \
     ca-certificates \
     unzip \
     git \
  && wget -q https://releases.hashicorp.com/terraform/1.0.5/terraform_1.0.5_linux_amd64.zip -O /tmp/terraform.zip \
  && wget -q https://github.com/terraform-linters/tflint/releases/download/v0.31.0/tflint_linux_amd64.zip -O /tmp/tflint.zip \
  && unzip /tmp/terraform.zip -d /usr/local/bin \
  && unzip /tmp/tflint.zip -d /usr/local/bin \
  && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/bin/bash"]
