#!/usr/bin/env bash

# runs after terraform deploys infra 

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

# leave blank we set dynamically below 
ENDPOINT_ID=""

# Get the kafka key, cert, and create the trustore client.keystore.p12
# avn service user-kafka-java-creds --username avnadmin -p secret [servicename]
avn service user-kafka-java-creds --username avnadmin --project $PROJECT_NAME $AVN_KAFKA1_SVC_NAME -d ./service-creds

# $SCHEMA_REGISTRY_URL is the "real" (primary) schema registry URL in your "primary" Kafka service. 
# $USERNAME and $PASSWORD are the "real" (primary) Schema Registry credentials, e.g. `avnadmin` and its password.
# https://avnadmin:XXXXXXXXXXX@kafka-primary-sa-chrism-test.aivencloud.com:24952
SCHEMA_REGISTRY_URL="https://$KAFKA_ADMIN_USER:$AVN_KAFKA1_SVC_PASSWORD@$AVN_KAFKA1_SVC_NAME-$PROJECT_NAME.aivencloud.com:24952"

echo "Step 1 Aiven Ops: Set requisite ACL access"
echo "Aiven Ops must execute the below command(s) with requisite project(s):"
echo "AVN-PROD-RW acl set --project $PROJECT_NAME service_integrations:kafka_*_schema_registry_proxy"
# i.e.:
# AVN-PROD-RW acl set --project sa-demo  service_integrations:kafka_*_schema_registry_proxy
echo

echo "Step 2 Customers: Setup Proxy and Create Integration"
echo "To setup the proxy, customers will need to execute some commands using the Aiven Client (or the API)"
echo
echo "2-A. Create the service integration endpoint"
# We execute the following command in the project that contains the "dependent" (secondary) Kafka service
# WHERE $SCHEMA_REGISTRY_URL is the "real" (primary) schema registry URL in your "primary" Kafka service. 
# AND $USERNAME and $PASSWORD are the "real" (primary) Schema Registry credentials, e.g. `avnadmin` and its password.
avn service integration-endpoint-create --project $PROJECT_NAME -t external_schema_registry -d $ENDPOINT_NAME -c url="$SCHEMA_REGISTRY_URL" -c authentication="basic" -c basic_auth_username="$KAFKA_ADMIN_USER" -c basic_auth_password="$AVN_KAFKA1_SVC_PASSWORD"

echo "2-B. Create the integration between the "dependent" (secondary) Kafka service and the endpoint we created above"
# get the endpoint ID from here
ENDPOINT_ID=`avn service integration-endpoint-list --project $PROJECT_NAME | grep $ENDPOINT_NAME | awk '{print $1}'`

#avn service integration-create --project $PROJECT_NAME -t schema_registry_proxy -S $ENDPOINT_ID -d $KAFKA_SERVICE
avn service integration-create --project $PROJECT_NAME -t schema_registry_proxy -S $ENDPOINT_ID -d $AVN_KAFKA2_SVC_NAME

echo

# Step 3 Customers: Validation 
# After running the above commands, and accessing the "dependent" (secondary) Kafka service's page in the Console,
# the `Schema Registry` section should now be visable with its own URL and credentials. (Note this can also be validated in the API responses too.) 
# You can now send Schema Registry requests to the "dependent" (secondary) Kafka service, and they will be `proxied` to the "real" (primary) Schema Registry URL.
