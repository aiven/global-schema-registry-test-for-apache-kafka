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
