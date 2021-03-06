variable "realm_backend_access_key" {}
variable "realm_backend_storage_account_name" {}
variable "realm_backend_container_name" {}

variable "subscription_id" {}
variable "service_principal_app_id" {}
variable "service_principal_password" {}
variable "service_principal_tenant" {}

variable "resource_group_name" {}
variable "resource_group_location" {}

variable "realm" {}
variable "environment" {}

variable "virtual_network_address_space" {
  type = list(string)
}

variable "subnet_address_prefix_env-default" {}
variable "subnet_address_prefix_env-application" {}
variable "subnet_address_prefix_env-data" {}

variable "subnet_service_endpoints_env-data" {
  type = list(string)
}

variable "realm_common_tags" {
  type = map(string)
}
