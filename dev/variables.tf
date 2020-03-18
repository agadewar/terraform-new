# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "tfstate_resource_group" {
  description = "The environment the resource is deployed"
  type        = string
}

variable "tfstate_storage_account" {
  description = "The environment the resource is deployed"
  type        = string
}

variable "tfstate_container_name" {
  description = "The environment the resource is deployed"
  type        = string
}

variable "tfstate_access_key" {
  description = "The environment the resource is deployed"
  type        = string
}

variable "subscription_id" {
  description = "The environment the resource is deployed"
  type        = string
}

variable "client_id" {
  description = "The environment the resource is deployed"
  type        = string
}

variable "client_secret" {
  description = "The environment the resource is deployed"
  type        = string
}

variable "tenant_id" {
  description = "The environment the resource is deployed"
  type        = string
}

variable "environment" {
  description = "The environment the resource is deployed"
  type        = string
}

variable "location" {
  description = "The location where the resource is deployed"
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

