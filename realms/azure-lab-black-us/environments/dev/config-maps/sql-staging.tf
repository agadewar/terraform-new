resource "kubernetes_config_map" "sql_staging" {
  metadata {
    name      = "sql-staging"
    namespace = local.namespace
  }

  data = {
    "hostname" = var.sql_staging_hostname
    "api_username" = var.sql_app_svc_api_username
    "etl_username" = var.sql_app_svc_etl_username
  }
}