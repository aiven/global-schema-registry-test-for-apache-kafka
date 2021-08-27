resource "aiven_project_vpc" "primary" {
    project = var.avn_kafka1_svc_project_id
    cloud_name = var.avn_kafka1_svc_cloud
    network_cidr = "10.1.0.0/24"

    timeouts {
        create = "5m"
    }
}

# Note: Only one project VPC allowed per cloud
#resource "aiven_project_vpc" "dependent" {
#    project = var.avn_kafka2_svc_project_id
#    cloud_name = var.avn_kafka2_svc_cloud
#    network_cidr = "10.2.0.0/24"
#
#    timeouts {
#        create = "5m"
#    }
#}