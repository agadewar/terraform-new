variable "realm_backend_access_key" {}
variable "realm_backend_storage_account_name" {}
variable "realm_backend_container_name" {}

variable "env_backend_access_key" {}
variable "env_backend_storage_account_name" {}
variable "env_backend_container_name" {}

variable "cloud" {}
variable "realm" {}
variable "region" {}
variable "dns_realm" {}
variable "environment" {}

variable "service_principal_app_id" {}
variable "service_principal_tenant" {}
variable "service_principal_password" {}

variable "global_subscription_id" {}

variable "resource_group_name" {}

# variable "create_cname_api" {}

# variable "portal_ip" {}

variable "realm_common_tags" {
  type = map(string)
}

