resource "kubernetes_secret" "sisense" {
  metadata {
    name = "sisense"
    namespace = local.namespace
  }

  data = {
      secret = var.sisense_secret
      Sisense__SharedSecret = var.Sisense__SharedSecret
  }
}