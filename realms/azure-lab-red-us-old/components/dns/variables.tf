variable "realm_backend_access_key" {}
variable "realm_backend_storage_account_name" {}
variable "realm_backend_container_name" {}

variable "cloud" {}
variable "region" {}
variable "dns_realm" {}

variable "subscription_id" {}
variable "service_principal_app_id" {}
variable "service_principal_tenant" {}
variable "service_principal_password" {}

variable "resource_group_name" {}

variable "realm_common_tags" {
  type = map(string)
}

