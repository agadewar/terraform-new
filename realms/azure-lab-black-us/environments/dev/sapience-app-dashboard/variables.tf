variable "environment" {}

variable "cosmosdb_key" {}

variable "appinsights_key" {}

variable "realm_common_tags" {
    type = "map"
}
variable "environment_common_tags" {
    type = "map"
}