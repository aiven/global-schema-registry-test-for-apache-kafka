#!/usr/bin/env bash

# ref: Additional Karapace Quickstart
# https://github.com/aiven/karapace/blob/master/README.rst 

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
AVN_KAFKA2_SVC_PASSWORD="$(avn service user-list --format '{username} {password}' --project $PROJECT_NAME $AVN_KAFKA2_SVC_NAME | awk '{print $2}')"

# $PRIMARY_SCHEMA_REGISTRY_URL is the "real" (primary) schema registry URL in your "primary" Kafka service. 
# $USERNAME and $PASSWORD are the "real" (primary) Schema Registry credentials, e.g. `avnadmin` and its password.
# https://avnadmin:XXXXXXXXXXX@kafka-primary-sa-chrism-test.aivencloud.com:24952
PRIMARY_SCHEMA_REGISTRY_URL="https://$KAFKA_ADMIN_USER:$AVN_KAFKA1_SVC_PASSWORD@public-$AVN_KAFKA1_SVC_NAME-$PROJECT_NAME.aivencloud.com:24952"
SECONDARY_SCHEMA_REGISTRY_URL="https://$KAFKA_ADMIN_USER:$AVN_KAFKA2_SVC_PASSWORD@public-$AVN_KAFKA2_SVC_NAME-$PROJECT_NAME.aivencloud.com:24952"

# re-enable for debug sensitive shows avnadmin password to console
#echo
#echo "============================================================="
#echo "PRIMARY_SCHEMA_REGISTRY_URL:   $PRIMARY_SCHEMA_REGISTRY_URL"
#echo "SECONDARY_SCHEMA_REGISTRY_URL: $SECONDARY_SCHEMA_REGISTRY_URL"
#echo "============================================================="
#echo

echo
echo "Making API calls to the PRIMARY_SCHEMA_REGISTRY_URL"
echo

echo "Register a new version of a schema under the subject 'Kafka-key'"
curl -X POST -H "Content-Type: application/vnd.schemaregistry.v1+json" \
--data '{"schema": "{\"type\": \"string\"}"}' \
"$PRIMARY_SCHEMA_REGISTRY_URL/subjects/kafka-key/versions"

echo "Register a new version of a schema under the subject 'Kafka-value'"
curl -X POST -H "Content-Type: application/vnd.schemaregistry.v1+json" \
--data '{"schema": "{\"type\": \"string\"}"}' \
"$PRIMARY_SCHEMA_REGISTRY_URL/subjects/kafka-value/versions"

echo "Register an existing schema to a new subject name"
curl -X POST -H "Content-Type: application/vnd.schemaregistry.v1+json" \
--data "{\"schema\": $(curl -s $PRIMARY_SCHEMA_REGISTRY_URL/subjects/Kafka-value/versions/latest | jq '.schema')}" \
"$PRIMARY_SCHEMA_REGISTRY_URL/subjects/kafka2-value/versions"

echo
echo "All below queries use the SECONDARY_SCHEMA_REGISTRY_URL for validating"
echo

echo "Subjects:"
curl -s -X GET "$SECONDARY_SCHEMA_REGISTRY_URL/subjects" | jq .
echo

echo "Topics:"
curl -s -X GET "$SECONDARY_SCHEMA_REGISTRY_URL/topics" | jq .
echo

echo "Fetch a schema by globally unique ID 1"
curl -s -X GET "$SECONDARY_SCHEMA_REGISTRY_URL/schemas/ids/1" | jq .
echo

echo "Get info on our terraform created topic 'topics primary-topic-tf'"
curl -s -X GET "$SECONDARY_SCHEMA_REGISTRY_URL/topics/primary-topic-tf" | jq .
echo

echo 'Show config compat level'
curl -s -X GET "$SECONDARY_SCHEMA_REGISTRY_URL/config" | jq .
echo

echo "List all schema versions registered under the subject 'primary-schema-tf' querying SECONDARY_SCHEMA_REGISTRY_URL"
curl -X GET $SECONDARY_SCHEMA_REGISTRY_URL/subjects/primary-schema-tf/versions
echo
