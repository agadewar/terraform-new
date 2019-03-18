variable "realm" {}
variable "environment" {}

variable "canopy_container_registry_hostname" {}

variable "kubernetes_namespace_default_token" {}

variable "realm_common_tags" {
    type = "map"
}
variable "environment_common_tags" {
    type = "map"
}