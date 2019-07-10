variable "realm" {}

variable "subscription_id" {}
variable "service_principal_app_id" {}
variable "service_principal_tenant" {}
variable "service_principal_password" {}

variable "resource_group_name" {}

variable "dns_contributor_role_assignment_ids" {
   type = "list"
}

variable "realm_common_tags" {
    type = "map"
}