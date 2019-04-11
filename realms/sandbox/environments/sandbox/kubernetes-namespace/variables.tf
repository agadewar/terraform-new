variable "backend_access_key" {}
variable "backend_storage_account_name" {}
variable "backend_container_name" {}

variable "subscription_id" {}
variable "resource_group_name" {}
variable "resource_group_location" {}

variable "realm" {}

variable "environment" {}

variable "realm_common_tags" {
    type = "map"
}
variable "environment_common_tags" {
    type = "map"
}