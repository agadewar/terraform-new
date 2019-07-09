variable "realm_backend_access_key" {}
variable "realm_backend_storage_account_name" {}
variable "realm" {}
variable "subscription_id" {}
variable "service_principal_app_id" {}
variable "service_principal_tenant" {}
variable "service_principal_password" {}
variable "sapience_container_registry_hostname" {}
variable "sapience_container_registry_username" {}
variable "sapience_container_registry_password" {}

variable "resource_group_name" {}
variable "resource_group_location" {}

variable "jenkins_source_ranges_allowed" {
  type = list(string)
}

variable "realm_common_tags" {
  type = map(string)
}

