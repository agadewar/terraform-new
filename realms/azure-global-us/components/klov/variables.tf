variable "realm_backend_access_key" {}
variable "realm_backend_storage_account_name" {}
variable "realm_backend_container_name" {}

variable "cloud" {}
variable "region" {}
variable "dns_realm" {}
variable "realm" {}

variable "subscription_id" {}
variable "service_principal_app_id" {}
variable "service_principal_tenant" {}
variable "service_principal_password" {}

variable "resource_group_name" {}
variable "resource_group_location" {}

variable "klov_server_admin_name" {}
variable "klov_server_admin_key" {}

variable "klov_source_ranges_allowed" {
    type = "list" 
}
variable "realm_common_tags" {
    type = "map"
}
