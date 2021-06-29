resource "kubernetes_config_map" "cosmos-db" {
  metadata {
    name      = "cosmos-db"
    namespace = local.namespace
  }

  data = {
      #"dashboard" = "https://sapience-app-dashboard-lab-us-dev.privatelink.documents.azure.com:443/"
      "dashboard" = "https://sapience-app-dashboard-lab-eu-dev.documents.azure.com:443/"
      "alerts" = "https://sapience-app-alerts-lab-eu-dev.documents.azure.com:443/"
  }
}