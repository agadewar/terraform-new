variable "backend_access_key" {}
variable "backend_storage_account_name" {}

variable "subscription_id" {}
variable "resource_group_name" {}

variable "realm" {}
variable "environment" {}

variable "nginx_ingress_replica_count" {}
variable "nginx_ingress_controller_dns_records" {
    type = "list"
}

variable "realm_common_tags" {
    type = "map"
}