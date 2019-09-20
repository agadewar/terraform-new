variable "env_backend_access_key" {}
variable "env_backend_storage_account_name" {}
variable "env_backend_container_name" {}

variable "realm" {}
variable "environment" {}

variable "subscription_id" {}
variable "service_principal_app_id" {}
variable "service_principal_password" {}
variable "service_principal_tenant" {}

# RESOURCE GROUPS
variable "resource_group_name" {}
variable "resource_group_location" {}
variable "realm_common_tags" {
  type = map(string)
}

# WINDOWS ADMINISTRATOR
variable "sapience_cgp_prod_admin_username" {}
variable "sapience_cgp_prod_admin_password" {}

# WHITELIST IP ADDRESSES
variable "ip_sapience_dallas_office" {
  default = ""
}
variable "ip_sapience_pune_office" {
  default = ""
}

# TAGS
variable "environment_common_tags" {
  type = map(string)
}

