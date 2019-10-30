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

# PASSWORDS FOR OLD VMs IN THE WRONG SUBNET
// variable "sisense_appquery_01_admin_username" {}
// variable "sisense_appquery_01_admin_password" {}
// variable "sisense_appquery_02_admin_username" {}
// variable "sisense_appquery_02_admin_password" {}
// variable "sisense_build_admin_username" {}
// variable "sisense_build_admin_password" {}

# PASSWORDS FOR NEW VMs IN THE CORRECT SUBNET
variable "sisense_appquery_001_admin_username" {}
variable "sisense_appquery_001_admin_password" {}
variable "sisense_appquery_002_admin_username" {}
variable "sisense_appquery_002_admin_password" {}
variable "sisense_build_001_admin_username" {}
variable "sisense_build_001_admin_password" {}

variable "ip_sapience_dallas_office" {}
variable "ip_sapience_pune_office" {}
variable "ip_banyan_office" {}

variable "environment_common_tags" {
  type = map(string)
}

