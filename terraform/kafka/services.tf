# Kafka service
# ref: https://github.com/aiven/terraform-provider-aiven/blob/master/docs/resources/kafka.md
resource "aiven_kafka" "kafka-service1" {
  project        = var.avn_kafka1_svc_project_id
  cloud_name     = var.avn_kafka1_svc_cloud
  plan           = var.avn_kafka1_svc_plan
  service_name   = var.avn_kafka1_svc_name
  project_vpc_id = aiven_project_vpc.primary.id

  kafka_user_config {
    kafka_rest      = true
    schema_registry = true
    kafka_version   = var.avn_kafka1_svc_version

    kafka {
      auto_create_topics_enable = true
      group_max_session_timeout_ms = 70000
      log_retention_bytes          = 1000000000
    }

    public_access {
      kafka      = true
      kafka_rest = true
      schema_registry = true
    }
  }
  depends_on = [aiven_project_vpc.primary]
}

# Kafka1 topic
resource "aiven_kafka_topic" "kafka-topic1" {
  project      = var.avn_kafka1_svc_project_id
  service_name = aiven_kafka.kafka-service1.service_name
  topic_name   = "test-kafka1-topic"
  partitions   = 3
  replication  = 2
}

resource "aiven_kafka" "kafka-service2" {
  project        = var.avn_kafka2_svc_project_id
  cloud_name     = var.avn_kafka2_svc_cloud
  plan           = var.avn_kafka2_svc_plan
  service_name   = var.avn_kafka2_svc_name
  project_vpc_id = aiven_project_vpc.primary.id

  kafka_user_config {
    kafka_rest      = true
    # keep below false or else: 'Cannot enable schema_registry_proxy integration when Schema Registry / Karapace is enabled on destination service'
    schema_registry = false
    kafka_version   = var.avn_kafka2_svc_version

    kafka {
      auto_create_topics_enable = true
      group_max_session_timeout_ms = 70000
      log_retention_bytes          = 1000000000
    }

    public_access {
      kafka      = true
      kafka_rest = true
      schema_registry = true
    }
  }
  depends_on = [aiven_project_vpc.primary]
}

# Kafka2 topic
resource "aiven_kafka_topic" "kafka-topic2" {
  project      = var.avn_kafka2_svc_project_id
  service_name = aiven_kafka.kafka-service2.service_name
  topic_name   = "test-kafka2-topic"
  partitions   = 3
  replication  = 2
}

# Kafka Schema configuration in the primary 
resource "aiven_kafka_schema_configuration" "schema-config" {
  project             = var.avn_kafka1_svc_project_id
  service_name        = aiven_kafka.kafka-service1.service_name
  compatibility_level = "BACKWARD"
}

# Kafka Schema in the primary using external file
resource "aiven_kafka_schema" "kafka-schema" {
  project      = var.avn_kafka1_svc_project_id
  service_name = aiven_kafka.kafka-service1.service_name
  subject_name = "kafka1-schema"
  schema       = file("${path.module}/external_schema.avsc")
}
