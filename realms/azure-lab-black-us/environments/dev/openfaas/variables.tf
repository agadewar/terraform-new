variable "realm_backend_access_key" {}
variable "realm_backend_storage_account_name" {}
variable "realm_backend_container_name" {}

variable "global_subscription_id" {}

variable "service_principal_app_id" {}
variable "service_principal_tenant" {}
variable "service_principal_password" {}

variable "resource_group_name" {}

variable "cloud" {}
# variable "realm" {}
variable "region" {}
variable "dns_realm" {}
variable "environment" {}

variable "openfaas_gateway_nodeport" {}

variable "realm_common_tags" {
  type = map(string)
}