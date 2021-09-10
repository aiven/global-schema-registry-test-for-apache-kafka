# Shared Global Schema Registry Test

---
### Overview
- Deploys infrastructure via Terraform 
  - two kafka services and requisite dependencies
- Creates and configures (access, etc. for) the requisite integration-endpoint, proxy, etc.
#### Global Schema Registry Delegation Logical Diagram

![global schema registry delegation](./images/global-schema-registry-delegation.png?raw=true)

---
##### Deploy the test infrasture and create/configure the integration endpoint
- deploy all requisite infrastructure simply by executing the main script
  - `./bin/DEPLOY-terraform-infra.sh`

- Once this main wrapper script is executed, all dependency scripts, etc. will be executed as well.
  - Now, we can validate on the "dependent" Kafka service's page in the Console (and in the API responses) will appear the Schema Registry section with its own URL and credentials. You can now send Schema Registry requests to the "dependent" Kafka service, they will be proxied to the "real" Schema Registry URL.

---
##### Destroy test terraform infrastructure and delete its test integration-endpoint
- `./bin/DESTROY-terraform-infra.sh`

---

##### TODO: 
- Add automated global schema registry testing
- Update this doc