variable "environment" {}

variable "sql_server_administrator_password" {}

variable "realm_common_tags" {
    type = "map"
}
variable "environment_common_tags" {
    type = "map"
}

variable "sisense_secret" {}