variable "realm_backend_access_key" {}
variable "realm_backend_storage_account_name" {}
variable "realm_backend_container_name" {}

variable "cloud" {}
variable "realm" {}

variable "subscription_id" {}
variable "service_principal_app_id" {}
variable "service_principal_tenant" {}
variable "service_principal_password" {}

variable "resource_group_name" {}
variable "resource_group_location" {}

variable "kubernetes_version" {}

variable "kubernetes_agent_pool_profile_1_vm_size" {}
variable "kubernetes_agent_pool_profile_1_os_disk_size_gb" {}
variable "kubernetes_min_count" {}
variable "kubernetes_max_count" {}
variable "kubernetes_autoscaler_version" {}

variable "realm_common_tags" {
  type = map(string)
}


