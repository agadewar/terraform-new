variable "realm_backend_access_key" {}
variable "realm_backend_storage_account_name" {}
variable "realm_backend_container_name" {}

variable "env_backend_access_key" {}
variable "env_backend_storage_account_name" {}
variable "env_backend_container_name" {}

variable "realm" {}
variable "environment" {}

variable "subscription_id" {}
variable "service_principal_app_id" {}
variable "service_principal_password" {}
variable "service_principal_tenant" {}


variable "resource_group_name" {}
variable "resource_group_location" {}

variable "realm_common_tags" {
  type = map(string)
}

variable "talend_admin_username" {}
variable "talend_admin_password" {}

variable "ip_sapience_dallas_office" {}
variable "ip_sapience_pune_office" {}
variable "ip_sapience_pune2_office" {}

variable "environment_common_tags" {
  type = map(string)
}

