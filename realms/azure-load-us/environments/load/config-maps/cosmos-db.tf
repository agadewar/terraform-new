resource "kubernetes_config_map" "cosmos-db" {
  metadata {
    name      = "cosmos-db"
    namespace = local.namespace
  }

  data = {
      "dashboard" = "https://sapience-app-dashboard-load-us-load.documents.azure.com:443/"
      "alerts" = "https://sapience-app-alerts-load-us-load.documents.azure.com:443/"
  }
}