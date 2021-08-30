#!/usr/bin/env bash

 #curl -H "Content-Type: application/vnd.kafka.avro.v2+json" -X POST -d \
 # '{"value_schema": "{\"namespace\": \"example.avro\", \"type\": \"record\", \"name\": \"simple\", \"fields\": \
 # [{\"name\": \"name\", \"type\": \"string\"}]}", "records": [{"value": {"name": "name0"}}]}' http://localhost:8081/topics/my_topic

# Globals
TFVARS=./terraform/.auto.tfvars
KAFKA_ADMIN_USER="avnadmin"

PROJECT_NAME=$(awk -F "= " '/avn_kafka1_svc_project_id/ {print $2}' ${TFVARS} | sed 's/"//g')
ENDPOINT_NAME=$(awk -F "= " '/avn_kafka1_svc_endpoint_name/ {print $2}' ${TFVARS} | sed 's/"//g')

# kafka
AVN_KAFKA1_SVC_NAME=$(AWK -F "= " '/avn_kafka1_svc_name/ {print $2}' ${TFVARS} | sed 's/"//g')
AVN_KAFKA2_SVC_NAME=$(AWK -F "= " '/avn_kafka2_svc_name/ {print $2}' ${TFVARS} | sed 's/"//g')

# get project/service creds
AVN_KAFKA1_SVC_PASSWORD="$(avn service user-list --format '{username} {password}' --project $PROJECT_NAME $AVN_KAFKA1_SVC_NAME | awk '{print $2}')"

# $SCHEMA_REGISTRY_URL is the "real" (primary) schema registry URL in your "primary" Kafka service. 
# $USERNAME and $PASSWORD are the "real" (primary) Schema Registry credentials, e.g. `avnadmin` and its password.
# https://avnadmin:XXXXXXXXXXX@kafka-primary-sa-chrism-test.aivencloud.com:24952
SCHEMA_REGISTRY_URL="https://$KAFKA_ADMIN_USER:$AVN_KAFKA1_SVC_PASSWORD@public-$AVN_KAFKA1_SVC_NAME-$PROJECT_NAME.aivencloud.com:24952"
echo "SCHEMA_REGISTRY_URL: $SCHEMA_REGISTRY_URL"

curl -X GET "$SCHEMA_REGISTRY_URL/subjects"
