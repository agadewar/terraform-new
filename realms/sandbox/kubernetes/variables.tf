variable "backend_access_key" {}
variable "backend_storage_account_name" {}
variable "backend_container_name" {}

variable "realm" {}

variable "subscription_id" {}

variable "service_principal_app_id" {}
variable "service_principal_tenant" {}

variable "kubernetes_version" {}
variable "kubernetes_agent_pool_profile_1_vm_size" {}
variable "kubernetes_min_count" {}
variable "kubernetes_max_count" {}
variable "kubernetes_password" {}
variable "kubernetes_linux_profile_ssh_key_loc" {}

variable "common_tags" {
    type = "map"
}
