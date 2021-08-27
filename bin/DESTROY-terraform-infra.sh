#!/bin/bash

while true; do
    printf '\n'
    read -p "Are you sure you are ready to DESTROY all terraform deployed infrastructure and data?" yn
    case $yn in
        [Yy]* ) echo 'now executing terraform destroy'; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo "first we destroy the integration-endpoint"

./bin/destroy-endpoint-integration.sh

cd ./terraform/kafka

echo "now we destroy the terraform infra"
./bin/destroy

cd ../../

echo "Terraform Destroy Completed"
echo
