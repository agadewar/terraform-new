variable "env_backend_access_key" {}
variable "env_backend_storage_account_name" {}
variable "env_backend_container_name" {}

variable "realm" {}

variable "environment" {}

variable "kafka_bootstrap_servers" {}
variable "kafka_username" {}
variable "kafka_password" {}

variable "canopy_container_registry_hostname" {}
variable "canopy_device_service_deployment_replicas" {}
variable "canopy_device_service_deployment_request_memory" {}
variable "canopy_device_service_deployment_request_cpu" {}
variable "canopy_hierarchy_service_deployment_replicas" {}
variable "canopy_hierarchy_service_deployment_request_memory" {}
variable "canopy_hierarchy_service_deployment_request_cpu" {}
variable "canopy_user_service_deployment_replicas" {}
variable "canopy_user_service_deployment_request_memory" {}
variable "canopy_user_service_deployment_request_cpu" {}
variable "eventpipeline_leaf_broker_service_deployment_replicas" {}
variable "eventpipeline_leaf_broker_service_deployment_request_memory" {}
variable "eventpipeline_leaf_broker_service_deployment_request_cpu" {}
variable "eventpipeline_service_deployment_replicas" {}
variable "eventpipeline_service_deployment_request_memory" {}
variable "eventpipeline_service_deployment_request_cpu" {}


variable "sapience_container_registry_hostname" {}
variable "sapience_container_registry_username" {}
variable "sapience_container_registry_password" {}

# variable "sql_server_administrator_login" {}
# variable "sql_server_administrator_password" {}
variable "sql_server_canopy_username" {}
variable "sql_server_canopy_password" {}

variable "google_api_key" {
  default = ""
}

variable "realm_common_tags" {
  type = map(string)
}

variable "environment_common_tags" {
  type = map(string)
}

