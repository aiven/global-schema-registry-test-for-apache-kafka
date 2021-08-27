#!/usr/bin/env bash

# Globals
TFVARS=./terraform/.auto.tfvars
KAFKA_ADMIN_USER="avnadmin"

# leave blank we set dynamically below 
ENDPOINT_ID=""

PROJECT_NAME=$(awk -F "= " '/avn_kafka1_svc_project_id/ {print $2}' ${TFVARS} | sed 's/"//g')
ENDPOINT_NAME=$(awk -F "= " '/avn_kafka1_svc_endpoint_name/ {print $2}' ${TFVARS} | sed 's/"//g')

# kafka
AVN_KAFKA1_SVC_NAME=$(AWK -F "= " '/avn_kafka1_svc_name/ {print $2}' ${TFVARS} | sed 's/"//g')
AVN_KAFKA2_SVC_NAME=$(AWK -F "= " '/avn_kafka2_svc_name/ {print $2}' ${TFVARS} | sed 's/"//g')

# get project/service creds
AVN_KAFKA1_SVC_PASSWORD="$(avn service user-list --format '{username} {password}' --project $PROJECT_NAME $AVN_KAFKA1_SVC_NAME | awk '{print $2}')"
echo "AVN_KAFKA1_SVC_PASSWORD: $AVN_KAFKA1_SVC_PASSWORD"
echo "PROJECT_NAME: $PROJECT_NAME"

# get the endpoint ID from here
ENDPOINT_ID=`avn service integration-endpoint-list --project $PROJECT_NAME | grep $ENDPOINT_NAME | awk '{print $1}'`

# avn service integration-endpoint-delete --project sa-chrism-test d0d6caef-f063-4acd-9007-b22c098030ef
echo
avn service integration-endpoint-delete --project $PROJECT_NAME $ENDPOINT_ID

echo "show any remaining integration-endpoints in the project: $PROJECT_NAME"
avn service integration-endpoint-list --project $PROJECT_NAME

echo
