FROM gcr.io/cloud-builders/git

RUN apt-get update && \
  apt-get install -y wget && \
  wget https://github.com/mikefarah/yq/releases/download/v4.7.1/yq_linux_amd64 -O /usr/bin/yq && \
  chmod +x /usr/bin/yq

ENTRYPOINT ["/bin/bash"]
