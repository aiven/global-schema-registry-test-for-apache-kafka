# Shared
variable "avn_api_token" {}
variable "avn_card_id" {}

# Kafka primary
variable "avn_kafka1_svc_version" {}
variable "avn_kafka1_svc_project_id" {}
variable "avn_kafka1_svc_cloud" {}
variable "avn_kafka1_svc_plan" {}
variable "avn_kafka1_connect_svc_plan" {}
variable "avn_kafka1_svc_name" {}
variable "avn_kafka1_svc_endpoint_name" {}

# Kafka dependent secondary
variable "avn_kafka2_svc_version" {}
variable "avn_kafka2_svc_project_id" {}
variable "avn_kafka2_svc_cloud" {}
variable "avn_kafka2_svc_plan" {}
variable "avn_kafka2_connect_svc_plan" {}
variable "avn_kafka2_svc_name" {}
