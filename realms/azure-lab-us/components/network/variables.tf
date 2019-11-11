variable "subscription_id" {}
variable "service_principal_app_id" {}
variable "service_principal_tenant" {}
variable "service_principal_password" {}

variable "resource_group_name" {}
variable "resource_group_location" {}

variable "subnet_address_prefix" {}

variable "virtual_network_address_space" {
  type = list(string)
}

variable "subnet_address_prefix_default" {}
variable "subnet_address_prefix_aks-pool01" {}
variable "subnet_address_prefix_aks-pool02" {}
variable "subnet_address_prefix_aks-pool03" {}
variable "subnet_address_prefix_aks-pool04" {}

variable "subnet_service_endpoints" {
  type = list(string)
}

variable "realm_common_tags" {
  type = map(string)
}

