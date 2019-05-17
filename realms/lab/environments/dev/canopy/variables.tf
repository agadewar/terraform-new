variable "backend_access_key" {}
variable "backend_storage_account_name" {}
variable "backend_container_name" {}

variable "realm" {}
variable "environment" {}

variable "canopy_container_registry_hostname" {}

variable "sapience_container_registry_hostname" {}
variable "sapience_container_registry_username" {}
variable "sapience_container_registry_password" {}

variable "sql_server_administrator_login" {}
variable "sql_server_administrator_password" {}

# variable "canopy_amqp_password" {}

# variable "canopy_hierarchy_cosmos_password" {}

variable "google_api_key" {}

variable "realm_common_tags" {
    type = "map"
}
variable "environment_common_tags" {
    type = "map"
}