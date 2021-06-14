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
variable "api_auth_ips" {}

variable "kubernetes_red_version" {}

variable "kubernetes_pool01_vm_size" {}
variable "kubernetes_pool01_os_disk_size_gb" {}
variable "kubernetes_pool01_os_type" {}
variable "kubernetes_pool01_min_count" {}
variable "kubernetes_pool01_max_count" {}
variable "kubernetes_pool01_max_pods"  {}

variable "realm_common_tags" {
  type = map(string)
}
