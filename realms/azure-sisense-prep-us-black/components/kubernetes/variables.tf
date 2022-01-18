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

variable "kubernetes_system_vm_size" {}
variable "kubernetes_system_os_type" {}
variable "kubernetes_system_os_disk_size_gb" {}
variable "kubernetes_system_min_count" {}
variable "kubernetes_system_max_count" {}

variable "kubernetes_query_vm_size" {}
variable "kubernetes_query_os_type" {}
variable "kubernetes_query_os_disk_size_gb" {}
variable "kubernetes_query_min_count" {}
variable "kubernetes_query_max_count" {}

variable "kubernetes_application_vm_size" {}
variable "kubernetes_application_os_type" {}
variable "kubernetes_application_os_disk_size_gb" {}
variable "kubernetes_application_min_count" {}
variable "kubernetes_application_max_count" {}

variable "kubernetes_build_vm_size" {}
variable "kubernetes_build_os_type" {}
variable "kubernetes_build_os_disk_size_gb" {}
variable "kubernetes_build_min_count" {}
variable "kubernetes_build_max_count" {}

variable "realm_common_tags" {
  type = map(string)
}
