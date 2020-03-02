resource "kubernetes_secret" "auth0" {
  metadata {
    name = "auth0"
    namespace = local.namespace
  }

  data = {
      secret =  var.auth0_secret
  }
}