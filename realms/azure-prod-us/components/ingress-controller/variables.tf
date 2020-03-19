# variable "backend_access_key" {}
# variable "backend_storage_account_name" {}

variable "subscription_id" {}
variable "service_principal_app_id" {}
variable "service_principal_tenant" {}
variable "service_principal_password" {}

variable "resource_group_name" {}

variable "realm" {}

variable "nginx_ingress_replica_count" {}
variable "nginx_ingress_resource_requests_cpu" {}
variable "nginx_ingress_resource_requests_memory" {}

variable "realm_common_tags" {
  type = map(string)
}