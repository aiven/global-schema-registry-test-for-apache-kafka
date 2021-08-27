# Shared Global Schema Registry Test 

### Overview
- Deploys infrastructure via Terraform 
  - two kafka services and requisite dependencies
- Creates and configures (access, etc. for) the requisite integration-endpoint

##### Deploy the test infrasture and create/configure the integration endpoint
- `./bin/DEPLOY-terraform-infra.sh`

##### Destroy test terraform infrastructure and delete its test integration-endpoint
- `./bin/DESTROY-terraform-infra.sh`

##### TODO: 
- Add automated global schema registry testing
- Update this doc