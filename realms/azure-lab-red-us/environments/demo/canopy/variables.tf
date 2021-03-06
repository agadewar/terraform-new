variable "global_realm_backend_access_key" {}
variable "global_realm_backend_storage_account_name" {}
variable "global_realm_backend_container_name" {}

variable "realm_backend_access_key" {}
variable "realm_backend_storage_account_name" {}
variable "realm_backend_container_name" {}
variable "storage_account_access_key" {}

variable "env_backend_access_key" {}
variable "env_backend_storage_account_name" {}
variable "env_backend_container_name" {}

variable "resource_group_name" {} 

variable "cloud" {}
variable "realm" {}
variable "region" {}
variable "dns_realm" {}
variable "environment" {}

variable "kafka_bootstrap_servers" {}
variable "kafka_username" {}
variable "kafka_password" {}

variable "canopy_container_registry_hostname" {}

variable "canopy_auth0_service_deployment_replicas" {}
variable "canopy_auth0_service_deployment_request_memory" {}
variable "canopy_auth0_service_deployment_request_cpu" {}
variable "canopy_device_service_deployment_replicas" {}
variable "canopy_device_service_deployment_request_memory" {}
variable "canopy_device_service_deployment_request_cpu" {}
variable "canopy_hierarchy_service_deployment_replicas" {}
variable "canopy_hierarchy_service_deployment_request_memory" {}
variable "canopy_hierarchy_service_deployment_request_cpu" {}
variable "canopy_location_service_deployment_replicas" {}
variable "canopy_location_service_deployment_request_memory" {}
variable "canopy_location_service_deployment_request_cpu" {}
variable "canopy_marketplace_service_deployment_replicas" {}
variable "canopy_marketplace_service_deployment_request_memory" {}
variable "canopy_marketplace_service_deployment_request_cpu" {}
variable "canopy_notification_service_deployment_replicas" {}
variable "canopy_notification_service_deployment_request_memory" {}
variable "canopy_notification_service_deployment_request_cpu" {}
variable "canopy_schedule_service_deployment_replicas" {}
variable "canopy_schedule_service_deployment_request_memory" {}
variable "canopy_schedule_service_deployment_request_cpu" {}
variable "canopy_setting_service_deployment_replicas" {}
variable "canopy_setting_service_deployment_request_memory" {}
variable "canopy_setting_service_deployment_request_cpu" {}
variable "canopy_settings_service_deployment_replicas" {}
variable "canopy_settings_service_deployment_request_memory" {}
variable "canopy_settings_service_deployment_request_cpu" {}
variable "canopy_user_service_deployment_replicas" {}
variable "canopy_user_service_deployment_request_memory" {}
variable "canopy_user_service_deployment_request_cpu" {}
variable "canopy_v2_deployment_replicas" {}
variable "canopy_v2_deployment_request_memory" {}
variable "canopy_v2_deployment_request_cpu" {}
variable "eventpipeline_leaf_broker_service_deployment_replicas" {}
variable "eventpipeline_leaf_broker_service_deployment_request_memory" {}
variable "eventpipeline_leaf_broker_service_deployment_request_cpu" {}
variable "eventpipeline_service_deployment_replicas" {}
variable "eventpipeline_service_deployment_request_memory" {}
variable "eventpipeline_service_deployment_request_cpu" {}
variable "kpi_service_deployment_replicas" {}
variable "kpi_service_deployment_request_memory" {}
variable "kpi_service_deployment_request_cpu" {}

# variable "sapience_container_registry_hostname" {}
# variable "sapience_container_registry_username" {}
# variable "sapience_container_registry_password" {}

# variable "sql_server_administrator_login" {}
# variable "sql_server_administrator_password" {}
# variable "sql_server_canopy_username" {}
# variable "sql_server_canopy_password" {}

variable "influxdb_password" {}

variable "mysql_canopy_username" {}
variable "mysql_canopy_password" {}

variable "canopy_service_account_username" {}
variable "canopy_service_account_password" {}

variable "canopy_security_jwt_secret" {}

variable "google_api_key" {
  default = ""
}

variable "realm_common_tags" {
  type = map(string)
}

variable "environment_common_tags" {
  type = map(string)
}

