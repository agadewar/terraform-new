resource "kubernetes_config_map" "databases" {
  metadata {
    name      = "databases"
    namespace = local.namespace
  }

  data = {
      "sql_server_name"                  = "sapience-lab-us-demo.database.windows.net"
      "data_warehouse"                   = "edw"
      "api_service_account"              = "appsvc_api_user"
      "machine_learning_service_account" = "appsvc_ml_user"
  }
}