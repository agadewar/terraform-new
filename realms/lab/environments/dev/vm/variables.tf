variable "realm_backend_access_key" {}
variable "realm_backend_storage_account_name" {}
variable "realm_backend_container_name" {}

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

variable "sisense_appquery_01_admin_username" {}
variable "sisense_appquery_01_admin_password" {}
variable "sisense_appquery_02_admin_username" {}
variable "sisense_appquery_02_admin_password" {}
variable "sisense_build_admin_username" {}
variable "sisense_build_admin_password" {}

variable "ip_sapience_office" {
  default = ""
}

variable "ip_banyan_office" {
  default = ""
}

variable "ip_benjamin_john_home" {
  default = ""
}

variable "ip_steve_ardis_home" {
  default = ""
}

variable "environment_common_tags" {
  type = map(string)
}

