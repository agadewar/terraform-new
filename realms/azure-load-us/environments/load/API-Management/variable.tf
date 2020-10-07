
variable "realm" {
  type = string
  default = "load-us"
}
variable "environment" {
  type = string
  default = "load"
}

variable "subscription_id" {
  type = string
  default = "b78a61e7-f2ed-4cb0-8f48-6548408935e9"
}

variable "resource_group_name" {
  type = string
  default = "load-us"
}
variable "resource_group_location" {
  type = string
  default = "eastus"
}

#variable "realm_common_tags" {
#  type = map(string)
#}

#variable "environment_common_tags" {
#  type = map(string)
#}