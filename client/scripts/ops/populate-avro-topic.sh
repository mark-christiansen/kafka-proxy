#!/bin/bash

BASE=$(dirname "$0")
cd ${BASE}
. ../env.sh

[[ -z "$1" ]] && { echo "Topic not specified" ; exit 1; }
TOPIC=$1

[[ -z "$2" ]] && { echo "Number of messages not specified" ; exit 1; }
MSGS=$2 # messages per producer thread

KEY_SCHEMA='{"type":"record","name":"test","fields":[{"name":"id","type":"long"}]}'
VALUE_SCHEMA='{"type":"record","name":"test","fields":[{"name":"id","type":"long"},{"name":"name","type":"string"},{"name":"amount","type":"double"}]}'

for i in $(seq $MSGS); do echo "{\"id\":$i}~{\"id\":$i,\"name\":\"Test\",\"amount\":100.25}"; done | kafka-avro-console-producer \
--bootstrap-server $BOOTSTRAP_URL --producer.config $KAFKA_CONFIG -compression-codec lz4 --property key.schema=$KEY_SCHEMA \
--property value.schema=$VALUE_SCHEMA --property parse.key=true --property key.separator="~" --property schema.registry.url=$SCHEMA_URL \
--property basic.auth.credentials.source=USER_INFO --property basic.auth.user.info=$SCHEMA_USERNAME:$SCHEMA_PASSWORD --topic $TOPIC