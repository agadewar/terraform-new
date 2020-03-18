# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "tfstate_container_name" {
  description = "Create/Update Container in blob storage"
  type        = string
}

variable "tfstate_access_key" {
  description = "Access key to blob storage in production"
  type        = string
}

variable "subscription_id" {
  description = "Azure Subscription"
  type        = string
}

variable "client_id" {
  description = "Service Principal Account"
  type        = string
}

variable "client_secret" {
  description = "Service Principal Account"
  type        = string
}

variable "tenant_id" {
  description = "Azure Tenant ID"
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

variable "tfstate_resource_group" {
  description = "The environment the resource is deployed"
  type        = string
  default     = "devops"
}

variable "tfstate_storage_account" {
  description = "Blob storage in production"
  type        = string
  default     = "sapienceremotestate"
}