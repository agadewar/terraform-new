# variable "realm_backend_access_key" {}
# variable "realm_backend_storage_account_name" {}
# variable "realm_backend_container_name" {}
# variable "realm" {}
variable "global_subscription_id" {}

# variable "resource_group_name" {}
# variable "resource_group_location" {}

# variable "region" {}

variable "service_principal_app_id" {}
variable "service_principal_tenant" {}
variable "service_principal_password" {}

# variable "kubernetes_version" {}

# variable "kubernetes_pool01_vm_size" {}
# variable "kubernetes_pool01_os_type" {}
# variable "kubernetes_pool01_min_count" {}
# variable "kubernetes_pool01_max_count" {}

# variable "kubernetes_pool02_vm_size" {}
# variable "kubernetes_pool02_os_type" {}
# variable "kubernetes_pool02_min_count" {}
# variable "kubernetes_pool02_max_count" {}

# variable "subnet_address_prefix_kubernetes_pool01" {}
# variable "subnet_address_prefix_kubernetes_pool02" {}

# variable "kubernetes_linux_profile_ssh_key_loc" {}

variable "realm_common_tags" {
  type = map(string)
}
