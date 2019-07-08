variable "realm" {}

variable "subscription_id" {}
variable "resource_group_name" {}

variable "dns_contributor_role_assignment_ids" {
   type = "list"
}

variable "realm_common_tags" {
    type = "map"
}