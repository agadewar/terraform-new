variable "realm_backend_access_key" {}
variable "realm_backend_storage_account_name" {}
variable "realm_backend_container_name" {}
variable "environment" {}

variable "realm_common_tags" {
    type = "map"
}
variable "environment_common_tags" {
    type = "map"
}
variable "connectionstring_admin" {}
variable "connectionstring_adminimport" {}
variable "connectionstring_mad" {}
variable "connectionstring_edw" {}
variable "connectionstring_staging" {}
variable "cosmosdb_key_dashboard" {}
variable "connectionstring_dashboard_mongodb" {}
variable "cosmosdb_key_alerts" {}
variable "sisense_secret" {}
variable "auth0_secret" {}
variable "etl_secret" {}
variable "staging_password" {}
variable "connectionstring_mongo"{}
variable "auth0_alertrules_secret"{}
variable "auth0_alertrules_clientid"{}
variable "machine_learning_service_account_password"{}
variable "redis_dashboard_Password"{}
variable "Sisense__SharedSecret"{}
variable "Sisense__Auth0ClientSecret"{}
variable "Auth0ManagementApi__ClientSecret" {}
variable "ApimConfiguration__DelegationKey" {}
variable "ApimConfiguration__ClientSecret" {}
variable "UploadBlob__StorageAccountAccessKey" {}
variable "BulkUploadDbConfig__ConnString" {}
variable "Mongodb_integration_password" {}
variable "cyclr_client_id" {}
variable "cyclr_client_secret" {}