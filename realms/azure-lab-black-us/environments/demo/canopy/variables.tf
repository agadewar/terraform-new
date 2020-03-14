variable "global_realm_backend_access_key" {}
variable "global_realm_backend_storage_account_name" {}
variable "global_realm_backend_container_name" {}

variable "env_backend_access_key" {}
variable "env_backend_storage_account_name" {}
variable "env_backend_container_name" {}

variable "cloud" {}
variable "realm" {}
variable "region" {}
variable "dns_realm" {}
variable "environment" {}

variable "kafka_bootstrap_servers" {}
variable "kafka_username" {}
variable "kafka_password" {}

variable "canopy_container_registry_hostname" {}

# variable "sapience_container_registry_hostname" {}
# variable "sapience_container_registry_username" {}
# variable "sapience_container_registry_password" {}

# variable "sql_server_administrator_login" {}
# variable "sql_server_administrator_password" {}
# variable "sql_server_canopy_username" {}
# variable "sql_server_canopy_password" {}

variable "influxdb_password" {}

variable "mysql_canopy_username" {}
variable "mysql_canopy_password" {}

variable "google_api_key" {
  default = ""
}

variable "realm_common_tags" {
  type = map(string)
}

variable "environment_common_tags" {
  type = map(string)
}

