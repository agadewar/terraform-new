variable "backend_access_key" {}
variable "backend_storage_account_name" {}
variable "backend_container_name" {}
variable "realm" {}
variable "subscription_id" {}
variable "sapience_container_registry_hostname" {}
variable "sapience_container_registry_username" {}
variable "sapience_container_registry_password" {}
variable "resource_group_name" {}
variable "resource_group_location" {}
variable "load_balancer_source_ranges_allowed" {
    type = "list" 
}
variable "realm_common_tags" {
    type = "map"
}
