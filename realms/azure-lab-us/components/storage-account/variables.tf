variable "realm" {}

variable "subscription_id" {}
variable "service_principal_app_id" {}
variable "service_principal_tenant" {}
variable "service_principal_password" {}

variable "resource_group_name" {}

variable "resource_group_location" {}

variable "realm_common_tags" {
  type = map(string)
}

