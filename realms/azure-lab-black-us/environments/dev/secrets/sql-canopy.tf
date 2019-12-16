resource "kubernetes_secret" "sql_canopy" {
  metadata {
    name      = "sql-canopy"
    namespace = local.namespace
  }

  data = {
    "username" = var.kafka_username
    "password" = var.kafka_password
  }

  type = "Opaque"
}
