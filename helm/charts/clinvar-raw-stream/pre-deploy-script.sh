#!/bin/sh
# print command trace
set -x
# exit on fail
set -e

input_topic=broad-dsp-clinvar-dev
output_topic=clinvar-raw-dev
cluster=clingen-streams-dev
cluster_id=$(ccloud kafka cluster list | grep $cluster | awk '{print $1}')

kafka_properties_file=./kafka-dev.properties
if [[ ! -f "$kafka_properties_file" ]]; then
  echo "Kafka properties file not found: $kafka_properties_file "
  exit 1
fi

# reset offset on input topic
function topic_offset_to_zero {
    topic=$1
    group=$2
    kafka-consumer-groups --command-config ./kafka-dev.properties \
      --bootstrap-server pkc-4yyd6.us-east1.gcp.confluent.cloud:9092 \
      --reset-offsets \
      --to-offset 0 \
      --group "$group" \
      --topic "$topic" \
      --timeout 10000 \
      --execute
}

echo "Resetting input topic offset"
group=clinvar-raw-dev
topic_offset_to_zero $input_topic $group

echo "Deleting and recreating output topic"
# leave +e untoggled so topic deletes are allowed to fail
set +e
ccloud kafka topic delete --cluster $cluster_id $output_topic
set -e

# switch -e so exits on failure
ccloud kafka topic create --cluster $cluster_id $output_topic \
  --partitions 1 \
  --config retention.ms=-1
