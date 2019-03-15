variable "environment" {}
variable "subscription_id" {}
variable "backend_access_key" {}
variable "backend_storage_account_name" {}
variable "backend_container_name" {}
variable "ambassador_letsencrypt_email" {}
variable "ambassador_letsencrypt_acme_http_domain" {}
variable "ambassador_letsencrypt_acme_http_token"{}

variable "common_tags" {
    type = "map"
}