variable "environment" {}
variable "subscription_id" {}
variable "backend_access_key" {}
variable "backend_storage_account_name" {}
variable "backend_container_name" {}
variable "letsencrypt_email" {}
variable "letsencrypt_acme_http_domain" {}
variable "letsencrypt_acme_http_token"{}
variable "common_tags" {
    type = "map"
}