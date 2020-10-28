variable "realm_backend_access_key" {}
variable "realm_backend_storage_account_name" {}
variable "realm_backend_container_name" {}

variable "realm" {}
variable "environment" {}

variable "subscription_id" {}

variable "resource_group_name" {}
variable "resource_group_location" {}

variable "function_app_settings" {
  type = map(string)
}

variable "realm_common_tags" {
  type = map(string)
}

variable "environment_common_tags" {
  type = map(string)
}

