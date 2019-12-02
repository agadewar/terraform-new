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