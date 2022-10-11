#!/bin/bash

BASE=$(dirname "$0")
cd ${BASE}
. ../env.sh

[[ -z "$1" ]] && { echo "Topic not specified" ; exit 1; }
TOPIC=$1

[[ -z "$2" ]] && { echo "Partitions not specified" ; exit 1; }
PARTITIONS=$2

kafka-topics --bootstrap-server $BOOTSTRAP_URL --command-config $KAFKA_CONFIG --create --topic $TOPIC --partitions $PARTITIONS --replication-factor 3
