# Shared Global Schema Registry Test

---
### Overview
- Deploys infrastructure via Terraform 
  - two kafka services and requisite dependencies
- Creates and configures (access, etc. for) the requisite integration-endpoint, proxy, etc.
- Configures Primary Kafka and then accesses those resources from the secondary endoint via HAProxy
  - The queries to the secondary kafka services schema registry endpoint via the `test-schema-registry.sh` script are proxied to the primary kafka services schema registry--the logical flow is shown in below diagram:
#### Global Schema Registry Delegation Logical Diagram

![global schema registry delegation](./images/global-schema-registry-delegation.png?raw=true)

---
##### Deploy the test infrasture and create/configure the integration endpoint
- Deploy all requisite infrastructure simply by executing the main `DEPLOY` script
  - `./bin/DEPLOY-terraform-infra.sh`
    - which deploys requisite infrastructure via Terraform, and then runs several dependency scripts:
      - `bin/create-endpoint-and-integration.sh`
      - `bin/test-schema-registry.sh`

- Once this main wrapper script is executed, all dependency scripts, etc. will be executed as well.
  - We can then validate on the "dependent" Kafka service's page in the Console (and in the API responses) will appear the Schema Registry section with its own URL and credentials. You can now send Schema Registry requests to the "dependent" Kafka service, they will be `proxied` to the "real/primary/global" Schema Registry URL.

- The test script `bin/test-schema-registry.sh` is idempotent, and can be expanded/enhanced, and called directly if desired.

---
##### Show any/all existing infra deployed via Terraform
- `./bin/show-all-terraform-infra.sh`

---
##### Destroy all test terraform infrastructure (kafka instances, services, etc.) and delete its test integration-endpoint
- `./bin/DESTROY-terraform-infra.sh`