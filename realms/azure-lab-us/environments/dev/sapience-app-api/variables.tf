variable "environment" {}

variable "sql_server_administrator_password" {}
variable "sql_server_appsvc_api_user_password" {}
variable "realm_common_tags" {
    type = "map"
}
variable "environment_common_tags" {
    type = "map"
}

variable "sisense_secret" {}