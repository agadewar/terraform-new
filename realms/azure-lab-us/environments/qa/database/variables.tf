variable "realm_backend_access_key" {}
variable "realm_backend_storage_account_name" {}
variable "realm_backend_container_name" {}

variable "realm" {}
variable "environment" {}

variable "subscription_id" {}

variable "resource_group_name" {}
variable "resource_group_location" {}

variable "sql_server_administrator_login" {}
variable "sql_server_administrator_password" {}

variable "sql_database_sedw_requested_service_objective_name" {}
variable "sql_database_canopy_device_edition" {}
variable "sql_database_canopy_device_requested_service_objective_name" {}
variable "sql_database_canopy_eventpipeline_edition" {}
variable "sql_database_canopy_eventpipeline_requested_service_objective_name" {}
variable "sql_database_canopy_leafbroker_edition" {}
variable "sql_database_canopy_leafbroker_requested_service_objective_name" {}
variable "sql_database_canopy_user_edition" {}
variable "sql_database_canopy_user_requested_service_objective_name" {}
variable "sql_database_automation_edition" {}
variable "sql_database_automation_requested_service_objective_name" {}
variable "sql_database_mad_edition" {}
variable "sql_database_mad_requested_service_objective_name" {}
variable "sql_database_staging_edition" {}
variable "sql_database_staging_requested_service_objective_name" {}
variable "sql_database_edw_edition" {}
variable "sql_database_edw_requested_service_objective_name" {}


variable "realm_common_tags" {
  type = map(string)
}

variable "environment_common_tags" {
  type = map(string)
}

variable "ip_banyan_office" {}
variable "ip_benjamin_john_home" {}
variable "ip_sapience_dallas_office" {}
variable "ip_sapience_pune_office" {}
variable "ip_steve_ardis_home" {}

