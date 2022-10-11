# kafka-proxy

## Summary

This project is an example of using a forward proxy by Kafka clients to connect to [Confluent Cloud](https://www.confluent.io/confluent-cloud). Organizations may do this if they don't have permission to connect directly to Confluent Cloud from their internal network. The example is implemented using docker-compose to launch a [Kafka client](https://docs.confluent.io/platform/current/clients/index.html) in a network that cannot access the internet, and an [Nginx proxy](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/) that can access the internet (and thus access [Confluent Cloud](https://www.confluent.io/confluent-cloud)). Then, the [Confluent Cloud](https://www.confluent.io/confluent-cloud) DNS entries for bootstrapping to the brokers and connecting to the [Schema Registry](https://docs.confluent.io/platform/current/schema-registry/index.html) are overridden in the Kafka client's network by using Docker [links](https://docs.docker.com/network/links/). The links override the DNS values for the bootstrap URL and [Schema Registry](https://docs.confluent.io/platform/current/schema-registry/index.html) to point to the [Nginx proxy](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/). 

The Kafka client is implmented as a Docker image built from an [OpenJDK image](https://hub.docker.com/_/openjdk) that contains the [Confluent Platform](https://docs.confluent.io/platform/current/installation/installing_cp/zip-tar.html) downloaded inside the image. Scripts are added to use the `kafka-topics`, `kafka-consumer-groups`, `kafka-avro-console-consumer` and `kafka-avro-console-producer` to communicate to Confluent Cloud to execute operations like creating topics, deleting topics, consuming messages, and producing messages to Confluent Cloud. This Docker image is built by docker-compose when you load the environment.

## Requirements

This project requires the following tools:

* [docker & docker-compose](https://desktop.docker.com/mac/main/amd64/Docker.dmg?utm_source=docker&utm_medium=webreferral&utm_campaign=dd-smartbutton&utm_location=module)

## Setup and Launch 

To setup the project, make sure you have a [Confluent Cloud](https://www.confluent.io/confluent-cloud) account and have API keys and secrets for both broker access and Schema Registry access. Set these values in the `.env` file in the base of this project as shown below.
```
CONFLUENT_VERSION=7.2.2
NGINX_VERSION: 1.23.1
DOMAIN=mycompany.com
REGISTRY=com.mycompany
BOOTSTRAP_URL=pkc-abc123.us-east-1.aws.confluent.cloud
SCHEMA_URL=psrc-abc123.us-east-1.aws.confluent.cloud
SCHEMA_USERNAME=ABCDEFGHIJKL1234
SCHEMA_PASSWORD=AbcdEfg/HijklMNop1234567890/QRstuVwxyz
KAFKA_USERNAME=678ZYXW123456789
KAFKA_PASSWORD=efgHIjklmnOPqRstuVwxy/Z1234567890/abcD
```
Make sure docker is running on your machine (`docker ps -a`). If docker is running, execute this command in the base of this project (where `docker-compose.yml` is located) to launch the the Kafka client and Nginx proxy.
```
docker-compose up -d
```
To verify the containers are running and healthy, execute `docker ps -a`. You should see something like this in your terminal.
```
% docker ps -a
CONTAINER ID   IMAGE                  COMMAND                  CREATED              STATUS                        PORTS                       NAMES
a2b6affb5508   kafka-client:0.0.2     "bash -c 'touch /tmp…"   About a minute ago   Up About a minute (healthy)                               client
fb70b91e9bdd   ubuntu/nginx:latest    "/docker-entrypoint.…"   About a minute ago   Up About a minute             80/tcp                      proxy
```

## Test Connectivity

To test the conenctivity from the Kafka client, you must shell into the client container as shown below.
```
docker exec -it client /bin/bash
```
First, verify that the client cannot connect to the internet by executing `curl http://www.google.com`.
```
% curl http://www.google.com
curl: (6) Could not resolve host: www.google.com
```
Then when inside the client, execute `cd /scripts/ops` to change to the operational scripts directory. These scripts will use a Kafka configuration file located at `/conf/kafka.properties` and environment varaibles (execute `export` to see these environment variables). To run a test execute the following commands to test topic creation, producing to a topic with [Avro](https://avro.apache.org/) messages, and consuming from a topic with [Avro](https://avro.apache.org/) messages. Using [Avro](https://avro.apache.org/) will cause the clients to publish and pull schemas from the Schema Registry to test that connectivity.
```
% ./create-topic.sh avro-test 5

[2022-10-11 13:47:27,369] WARN The configuration 'schema.registry.url' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig)
[2022-10-11 13:47:27,369] WARN The configuration 'basic.auth.user.info' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig)
[2022-10-11 13:47:27,369] WARN The configuration 'basic.auth.credentials.source' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig)
Created topic avro-test.

% ./populate-avro-topic.sh avro-test 10

% ./consume-avro-topic-w-key.sh avro-test test

| KEY | SCHEMA_ID | VALUE | SCHEMA_ID | HEADERS
{"id":7} | 100002 | {"id":7,"name":"Test","amount":100.25} | 100003
{"id":9} | 100002 | {"id":9,"name":"Test","amount":100.25} | 100003
{"id":1} | 100002 | {"id":1,"name":"Test","amount":100.25} | 100003
{"id":2} | 100002 | {"id":2,"name":"Test","amount":100.25} | 100003
{"id":4} | 100002 | {"id":4,"name":"Test","amount":100.25} | 100003
{"id":6} | 100002 | {"id":6,"name":"Test","amount":100.25} | 100003
{"id":8} | 100002 | {"id":8,"name":"Test","amount":100.25} | 100003
{"id":5} | 100002 | {"id":5,"name":"Test","amount":100.25} | 100003
{"id":10} | 100002 | {"id":10,"name":"Test","amount":100.25} | 100003
{"id":3} | 100002 | {"id":3,"name":"Test","amount":100.25} | 100003
^CProcessed a total of 10 messages

% ./describe-consumer.sh test

[2022-10-11 13:50:14,762] WARN The configuration 'schema.registry.url' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig)
[2022-10-11 13:50:14,762] WARN The configuration 'basic.auth.user.info' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig)
[2022-10-11 13:50:14,762] WARN The configuration 'basic.auth.credentials.source' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig)

Consumer group 'test' has no active members.

GROUP           TOPIC           PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG             CONSUMER-ID     HOST            CLIENT-ID
test            avro-test       2          1               1               0               -               -               -
test            avro-test       1          5               5               0               -               -               -
test            avro-test       4          1               1               0               -               -               -
test            avro-test       3          2               2               0               -               -               -
test            avro-test       0          1               1               0               -               -               -

% ./delete-topics.sh avro-test

[2022-10-11 13:50:42,881] WARN The configuration 'schema.registry.url' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig)
[2022-10-11 13:50:42,882] WARN The configuration 'basic.auth.user.info' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig)
[2022-10-11 13:50:42,882] WARN The configuration 'basic.auth.credentials.source' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig)
```
If you see these results, you have successfully communicated to Confluent Cloud through the Nginx proxy.

## Nginx Proxy

The Nginx proxy is the [Ubuntu image](https://hub.docker.com/r/ubuntu/nginx) because the [official Nginx image](https://hub.docker.com/_/nginx) does not contain the module `ngx_stream_module.so`. I could have built a custom Docker image from this version and added this module but I chose this route because it was quicker. For a long term implementation I would definitely build a custom image from the [official Nginx image](https://hub.docker.com/_/nginx). The container loads up the file `nginx.conf` from the base of this project. It should be configured like shown below.
```
load_module '/usr/lib/nginx/modules/ngx_stream_module.so';

events {}
stream {
  map $ssl_preread_server_name $targetBackend {
     default $ssl_preread_server_name;
 }

 server {
   listen 9092;

   proxy_connect_timeout 1s;
   proxy_timeout 7200s;
   resolver 127.0.0.11;

   proxy_pass $targetBackend:9092;
   ssl_preread on;
 }

 server {
   listen 443;

   proxy_connect_timeout 1s;
   proxy_timeout 7200s;
   resolver 127.0.0.11;

   proxy_pass $targetBackend:443;
   ssl_preread on;
 }
}
```
There are two `servers` listening to port `9092` (Kafka Brokers) and `443` (Schema Registry). These will forward all traffic to these ports to Confluent Cloud because the proxy is in a network that has access to the network and does not have the Confluent Cloud DNS entries redirected to the proxy. Another interesting part of this configuration is the `resolver` which points at Docker's internal DNS server at `127.0.0.11`.

## Stop and Teardown

To stop and teardown the project run the command below in the base directory of this project.
```
docker-compose down
``` 

