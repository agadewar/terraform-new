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
variable "cloud" {}
variable "realm" {}

# VIRTUAL NETWORK - 10.106.0.0/16
variable "virtual_network_address_space" {type = list(string)}

# SUBNETS
variable "virtual_network_default_subnet" {}
variable "virtual_network_domain_subnet" {}
variable "virtual_network_subnet_service_endpoints" {}

# RESOURCE GROUP VARIABLES
variable "resource_group_name" {}
variable "resource_group_location" {}

# TAGS
variable "realm_common_tags" {type = map(string)}