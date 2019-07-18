variable "subscription_id" {}
variable "service_principal_app_id" {}
variable "service_principal_tenant" {}
variable "service_principal_password" {}

variable "resource_group_name" {}
variable "resource_group_location" {}


# OLD NETWORK
variable "virtual_network_address_space_old" {
  type = list(string)
}

variable "subnet_address_prefix" {}


# NEW NETWORK
variable "virtual_network_address_space" {
  type = list(string)
}

variable "subnet_address_prefix_default" {}
variable "subnet_address_prefix_dev-default" {}
variable "subnet_address_prefix_dev-application" {}
variable "subnet_address_prefix_dev-data" {}
variable "subnet_address_prefix_qa-default" {}
variable "subnet_address_prefix_qa-application" {}
variable "subnet_address_prefix_qa-data" {}
variable "subnet_address_prefix_aks-pool04" {}
variable "subnet_address_prefix_aks-pool03" {}
variable "subnet_address_prefix_aks-pool02" {}
variable "subnet_address_prefix_aks-pool01" {}



variable "subnet_service_endpoints" {
  type = list(string)
}

variable "realm_common_tags" {
  type = map(string)
}

