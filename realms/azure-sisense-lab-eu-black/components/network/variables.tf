variable "subscription_id" {}
variable "service_principal_app_id" {}
variable "service_principal_tenant" {}
variable "service_principal_password" {}

variable "resource_group_name" {}
variable "resource_group_location" {}

variable "virtual_network_address_space" {
  type = list(string)
}

variable "subnet_address_prefix_default" {}
variable "subnet_address_prefix_netapp" {}
variable "subnet_address_prefix_aks_northeu_sisense" {}
# variable "subnet_address_prefix_demo-default" {}
# variable "subnet_address_prefix_demo-application" {}
# variable "subnet_address_prefix_demo-data" {}
variable "subnet_address_prefix_aks-pool" {}

variable "subnet_service_endpoints" {
  type = list(string)
}

variable "realm_common_tags" {
  type = map(string)
}

