# CONNECTION VARIABLES
variable "subscription_id" {}
variable "service_principal_app_id" {}
variable "service_principal_tenant" {}
variable "service_principal_password" {}

# RESOURCE GROUP VARIABLES
variable "resource_group_name" {}
variable "resource_group_location" {}

# NETWORK VARIABLES
variable "subnet_address_prefix" {}
variable "subnet_address_prefix_default" {}
variable "subnet_address_prefix_managed-domain" {}
variable "virtual_network_address_space" {
  type = list(string)
}
variable "subnet_service_endpoints" {
  type = list(string)
}

variable "realm_common_tags" {
  type = map(string)
}
