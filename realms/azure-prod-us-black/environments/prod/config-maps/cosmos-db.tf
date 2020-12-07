resource "kubernetes_config_map" "cosmos-db" {
  metadata {
    name      = "cosmos-db"
    namespace = local.namespace
  }

  data = {
      "dashboard" = "https://sapience-app-dashboard-prod-us-prod.documents.azure.com:443/"
      "alerts" = "https://sapience-app-alerts-prod-us-prod.documents.azure.com:443/"
  }
}