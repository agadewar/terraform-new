resource "kubernetes_secret" "cosmos-db" {
  metadata {
    name = "cosmos-db"
    namespace = local.namespace
  }

  data = {
      alerts = var.cosmosdb_key_alerts
      dashboard = var.cosmosdb_key_dashboard
  }
}