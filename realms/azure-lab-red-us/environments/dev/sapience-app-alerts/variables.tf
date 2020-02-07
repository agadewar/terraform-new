variable "realm_backend_access_key" {}
variable "realm_backend_storage_account_name" {}
variable "realm_backend_container_name" {}
variable "environment" {}
variable "cosmosdb_key_alerts" {}
variable "realm_common_tags" {
    type = "map"
}
variable "environment_common_tags" {
    type = "map"
}