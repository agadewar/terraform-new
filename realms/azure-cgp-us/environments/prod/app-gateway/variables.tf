###################################################
# REALM VARIABLES (realm.azure-cgp-us.tfvars.vault)
###################################################

# PRODUCTION SUBSCRIPTION
variable "subscription_id" {}

# SERVICE PRINCIPAL - http://TerraformProduction
variable "service_principal_app_id" {}
variable "service_principal_password" {}
variable "service_principal_tenant" {}

# REMOTE TFSTATE STORAGE ACCOUNT
variable "realm_backend_access_key" {}
variable "realm_backend_storage_account_name" {}

# REALM
variable "realm" {}

# RESOURCE GROUPS
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

# DOMAIN ADMIN
variable "domain_admin_username" {}
variable "domain_admin_password" {}

# SAPIENCE SERVER LOCAL ADMIN ACCOUNT
variable "cgp_us_prod_web_app_001_admin_username" {}
variable "cgp_us_prod_web_app_001_admin_password" {}

# SQL SERVER LOCAL ADMIN ACCOUNT
variable "cgp_us_prod_sql_001_admin_username" {}
variable "cgp_us_prod_sql_001_admin_password" {}

# SAPIENCE OFFICES
variable "ip_sapience_dallas_office" {default = ""}
variable "ip_sapience_pune_office" {default = ""}

# TAGS
variable "environment_common_tags" {type = map(string)}
