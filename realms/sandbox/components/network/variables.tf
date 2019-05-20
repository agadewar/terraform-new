
variable "subscription_id" {}
variable "resource_group_name" {}
variable "resource_group_location" {}
variable "virtual_network_address_space" { type = "list" }
variable "subnet_address_prefix" {}
variable "subnet_service_endpoints" { type = "list" }

variable "realm_common_tags" {
  type = "map"
}
