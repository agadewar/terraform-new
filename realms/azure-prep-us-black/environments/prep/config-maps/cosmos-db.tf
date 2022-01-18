resource "kubernetes_config_map" "cosmos-db" {
  metadata {
    name      = "cosmos-db"
    namespace = local.namespace
  }

  data = {
      "dashboard" = "https://sapience-app-dashboard-prep-us-prep.documents.azure.com:443/"
      "alerts" = "https://sapience-app-alerts-prep-us-prep.documents.azure.com:443/"
  }
}