variable "realm" {}
variable "environment" {}

variable "canopy_container_registry_hostname" {}

variable "kubernetes_namespace_default_token" {}

variable "sql_server_administrator_login" {}
variable "sql_server_administrator_password" {}

variable "canopy_amqp_password" {}

variable "canopy_event_hub_password" {}

variable "canopy_hierarchy_cosmos_password" {}

variable "google_api_key" {}

variable "realm_common_tags" {
    type = "map"
}
variable "environment_common_tags" {
    type = "map"
}