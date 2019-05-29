variable "backend_access_key" {}
variable "backend_storage_account_name" {}
variable "backend_container_name" {}

variable "environment" {}
variable "subscription_id" {}

variable "resource_group_name" {}
variable "resource_group_location" {}


variable "sql_server_administrator_login" {}
variable "sql_server_administrator_password" {}


variable "realm_common_tags" {
    type = "map"
}
variable "environment_common_tags" {
    type = "map"
}


variable "ip_banyan_office"  {
  default = ""
}
variable "ip_benjamin_john_home" {
  default = ""
}
variable "ip_sapience_office" {
  default = ""
}
variable "ip_steve_ardis_home" {
  default = ""
}