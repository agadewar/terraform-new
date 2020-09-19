variable "realm_backend_access_key" {}
variable "realm_backend_storage_account_name" {}
variable "realm_backend_container_name" {}

variable "cloud" {}
# variable "realm" {}
variable "region" {}
variable "dns_realm" {}
variable "environment" {}

variable "subscription_id" {}

variable "service_principal_app_id" {}
variable "service_principal_tenant" {}
variable "service_principal_password" {}

variable "global_subscription_id" {}   ### make sure the DNS Zone Contributer IAM role is given to the service principal

variable "resource_group_name" {}
variable "ambassador_rbac_replicas" {}

variable "realm_common_tags" {
  type = map(string)
}

variable "environment_common_tags" {
  type = map(string)
}

