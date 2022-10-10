#!/bin/bash

BASE=$(dirname "$0")
cd ${BASE}
. ../env.sh

[[ -z "$1" ]] && { echo "Topic not specified" ; exit 1; }
TOPIC=$1
[[ -z "$2" ]] && { echo "Consumer group not specified" ; exit 1; }
GROUP=$2

# disable schema registry logging
export LOG_DIR="/tmp"
export SCHEMA_REGISTRY_LOG4J_LOGGERS="org.apache.kafka.clients.consumer=OFF"

kafka-avro-console-consumer --bootstrap-server $BOOTSTRAP_URL --consumer.config $KAFKA_CONFIG \
--property schema.registry.url=$SCHEMA_URL --property basic.auth.credentials.source=USER_INFO \
--property basic.auth.user.info=$SCHEMA_USERNAME:$SCHEMA_PASSWORD --topic $TOPIC --group $GROUP --from-beginning