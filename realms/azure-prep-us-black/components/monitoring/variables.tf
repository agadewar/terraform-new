variable "realm_common_tags" {
  type = map(string)
}

variable "monitoring_grafana_admin_password" {}
variable "monitoring_alertmanager_api_key" {}
variable "cloud" {}
# variable "realm" {}
variable "region" {}
variable "dns_realm" {}
variable "environment" {}