###################################################
# REALM VARIABLES (realm.azure-cgp-us.tfvars.vault)
###################################################

# PRODUCTION SUBSCRIPTION
variable "subscription_id" {}

# SERVICE PRINCIPAL - http://TerraformProduction
variable "service_principal_app_id" {}
variable "service_principal_tenant" {}
variable "service_principal_password" {}

# REMOTE TFSTATE STORAGE ACCOUNT
variable "realm_backend_access_key" {}
variable "realm_backend_storage_account_name" {}
variable "realm_backend_container_name" {}

# REALM
variable "realm" {}

# VIRTUAL NETWORK - 10.106.0.0/16
variable "virtual_network_address_space" {type = list(string)}

# RESOURCE GROUP VARIABLES
variable "resource_group_name" {}
variable "resource_group_location" {}

# TAGS
variable "realm_common_tags" {type = map(string)}

##########################################################################
# ENVIRONMENT VARIABLES (realm.azure-cgp-us.environment.prod.tfvars.vault)
##########################################################################

# STORAGE BLOB CONTAINER
variable "environment_backend_container_name" {}

# ENVIRONMENT
variable "environment" {}

# SUBNETS
variable "virtual_network_env_web-app-firewall" {}
variable "virtual_network_env_default" {}
variable "virtual_network_env_application" {}
variable "virtual_network_env_data" {}

# TAGS
variable "environment_common_tags" {type = map(string)}

