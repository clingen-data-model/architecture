FROM ubuntu:20.04

RUN apt-get update \
  && apt-get install --no-install-recommends -y \
     wget \
     git \
     ca-certificates \
  && wget https://github.com/roboll/helmfile/releases/download/v0.139.5/helmfile_linux_amd64 -O /usr/bin/helmfile \
  && chmod +x /usr/bin/helmfile \
  && wget https://github.com/yannh/kubeconform/releases/download/v0.4.7/kubeconform-linux-amd64.tar.gz -O /tmp/kubeconform.tar.gz \
  && tar -C /usr/bin -xzf /tmp/kubeconform.tar.gz kubeconform \
  && rm /tmp/kubeconform.tar.gz \
  && wget https://get.helm.sh/helm-v3.5.4-linux-amd64.tar.gz -O /tmp/helm.tar.gz \
  && tar -C /usr/bin -xzf /tmp/helm.tar.gz linux-amd64/helm --strip-components=1 \
  && rm /tmp/helm.tar.gz \
  && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/bin/bash"]
