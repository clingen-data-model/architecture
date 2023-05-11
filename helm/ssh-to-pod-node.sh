#!/usr/bin/env bash

########
# Uses kubectl and gcloud CLIs to ssh to the VM instance that a pod is running on
########

set -xeuo pipefail

if [ -z "$1" ]; then
    echo "Must provide pod name"
    exit 1
fi

pod_name="$1"

node_name=`kubectl -o json get "pod/${pod_name}" | jq -r '.spec.nodeName'`

if [ -z "$node_name" ]; then
    echo "Node name not found"
    exit 1
fi

if ! gcloud compute instances list | grep "$node_name"; then
    echo "Compute instance $node_name not found"
    exit 1
fi

gcloud compute ssh "$node_name"
