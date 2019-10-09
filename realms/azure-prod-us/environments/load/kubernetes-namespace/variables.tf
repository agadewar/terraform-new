variable "realm_backend_access_key" {}
variable "realm_backend_storage_account_name" {}
variable "realm_backend_container_name" {}

variable "service_principal_app_id" {}
variable "service_principal_tenant" {}
variable "service_principal_password" {}

variable "subscription_id" {}
variable "resource_group_name" {}
variable "resource_group_location" {}

variable "realm" {}

variable "environment" {}

variable "letsencrypt_cluster_issuer_email" {}

variable "realm_common_tags" {
    type = "map"
}
variable "environment_common_tags" {
    type = "map"
}