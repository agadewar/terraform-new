variable "environment" {}
variable "subscription_id" {}

variable "resource_group_name" {}
variable "resource_group_location" {}

variable "realm_common_tags" {
    type = "map"
}
variable "environment_common_tags" {
    type = "map"
}