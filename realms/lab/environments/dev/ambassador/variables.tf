variable "backend_access_key" {}
variable "backend_storage_account_name" {}
variable "backend_container_name" {}

variable "realm" {}
variable "environment" {}

variable "subscription_id" {}

variable "service_principal_app_id" {}
variable "service_principal_tenant" {}
variable "service_principal_password" {}

variable "resource_group_name" {}
variable "ambassador_rbac_replicas" {}

variable "realm_common_tags" {
  type = map(string)
}

variable "environment_common_tags" {
  type = map(string)
}

