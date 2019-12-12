resource "kubernetes_secret" "kafka" {
  metadata {
    name      = "kafka"
    namespace = local.namespace
  }

  data = {
    "username" = var.kafka_username
    "password" = var.kafka_password
  }

  type = "Opaque"
}
