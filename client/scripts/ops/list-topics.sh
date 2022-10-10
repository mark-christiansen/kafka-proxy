#!/bin/bash

BASE=$(dirname "$0")
cd ${BASE}
. ../env.sh

kafka-topics --bootstrap-server $BOOTSTRAP_URL --command-config $KAFKA_CONFIG --list