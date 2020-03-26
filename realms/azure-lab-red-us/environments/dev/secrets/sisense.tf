resource "kubernetes_secret" "sisense" {
  metadata {
    name = "sisense"
    namespace = local.namespace
  }

  data = {
      Sisense__Secret = var.sisense_secret
  }
}