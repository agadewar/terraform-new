variable "realm_backend_access_key" {}
variable "realm_backend_storage_account_name" {}
variable "realm_backend_container_name" {}
variable "env_backend_access_key" {}
variable "env_backend_storage_account_name" {}
variable "env_backend_container_name" {}
variable "environment" {}

variable "realm_common_tags" {
    type = "map"
}
variable "environment_common_tags" {
    type = "map"
}
variable "sisense_secret" {}
variable "connectionstring_staging" {}
variable "connectionstring_mad" {}