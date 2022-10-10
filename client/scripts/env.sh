#!/bin/bash

CONFLUENT_LOCAL_HOME="~/programs/confluent-7.2.2"

if [[ $PATH != *"$CONFLUENT_LOCAL_HOME"* ]]; then
  PATH=$PATH:$CONFLUENT_LOCAL_HOME/bin
  export PATH
fi

mkdir -p /conf

cat > /conf/kafka.properties <<EOF
bootstrap.servers=${BOOTSTRAP_URL}
security.protocol=SASL_SSL
sasl.mechanism=PLAIN
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="${KAFKA_USERNAME}" password="${KAFKA_PASSWORD}";
schema.registry.url=${SCHEMA_URL}
basic.auth.credentials.source=USER_INFO 
basic.auth.user.info=${SCHEMA_USERNAME}:${SCHEMA_PASSWORD}
EOF

KAFKA_CONFIG=/conf/kafka.properties