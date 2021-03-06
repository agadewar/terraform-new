variable "realm_backend_access_key" {}
variable "realm_backend_storage_account_name" {}
variable "env_backend_access_key" {}
variable "env_backend_storage_account_name" {}


variable "realm" {}
variable "environment" {}

variable "subscription_id" {}

variable "resource_group_name" {}

# variable "create_cname_api" {}

# variable "portal_ip" {}

variable "realm_common_tags" {
  type = map(string)
}

