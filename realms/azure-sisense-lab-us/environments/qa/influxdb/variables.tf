variable "realm_backend_access_key" {}
variable "realm_backend_storage_account_name" {}
variable "realm_backend_container_name" {}

variable "realm_common_tags" {
  type = map(string)
}

variable "environment" {}

variable "influxdb_password" {}

# variable "redis_password" {}
# variable "redis_cluster_enabled" {}
# variable "redis_cluster_slavecount" {}
