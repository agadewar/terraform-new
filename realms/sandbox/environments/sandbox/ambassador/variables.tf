variable "backend_access_key" {}
variable "backend_storage_account_name" {}
variable "backend_container_name" {}

variable "environment" {}

variable "subscription_id" {}
variable "resource_group_name" {}

variable "ambassador_letsencrypt_email" {}

variable "service_principal_app_id" {}
variable "service_principal_tenant" {}
variable "service_principal_password" {}

variable "realm_common_tags" {
    type = "map"
}
variable "environment_common_tags" {
    type = "map"
}