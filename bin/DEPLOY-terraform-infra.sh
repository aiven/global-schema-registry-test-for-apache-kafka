#!/bin/bash

cd ./terraform/kafka

./bin/init
./bin/plan
./bin/apply

cd ../../

echo

echo "Now creating endpoint and configuring integration..."
./bin/create-endpoint-and-integration.sh
echo

echo "Pause for 30 seconds to allow kafka services to become available before testing schema registry"
secs=$((30))
while [ $secs -gt 0 ]; do
   echo -ne "$secs\033[0K\r"
   sleep 1
   : $((secs--))
done

echo "Now testing access to PRIMARY (Global) schema registry via the SECONDARY schema registry URL--using ha proxy and endpoint, etc."
./bin/test-schema-registry.sh
echo