variable "subscription_id" {}
variable "service_principal_app_id" {}
variable "service_principal_password" {}
variable "service_principal_tenant" {}

variable "resource_group_name" {}
variable "resource_group_location" {}
variable "realm" {}

variable "virtual_network_address_space" {
  type = list(string)
}

variable "subnet_address_prefix_default" {}
variable "subnet_address_prefix_prod-default" {}
variable "subnet_address_prefix_prod-application" {}
variable "subnet_address_prefix_prod-data" {}
variable "subnet_address_prefix_demo-default" {}
variable "subnet_address_prefix_demo-application" {}
variable "subnet_address_prefix_demo-data" {}
variable "subnet_address_prefix_aks-pool04" {}
variable "subnet_address_prefix_aks-pool03" {}
variable "subnet_address_prefix_aks-pool02" {}
variable "subnet_address_prefix_aks-pool01" {}

variable "realm_common_tags" {
  type = map(string)
}

