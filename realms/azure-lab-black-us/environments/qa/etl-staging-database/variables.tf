variable "environment" {}

variable "sql_server_appsvc_etl_user_password" {}

variable "kafka_password" {}

variable "realm_common_tags" {
    type = "map"
}
variable "environment_common_tags" {
    type = "map"
}
