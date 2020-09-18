resource "kubernetes_secret" "auth-1" {
  metadata {
    name = "auth0"
    namespace = local.namespace
  }

  data = {
      alertrules_secret = var.auth0_alertrules_secret
      alertrules_clientid = var.auth0_alertrules_clientid
      secret =  var.auth0_secret
      Sisense__Auth0ClientSecret = var.Sisense__Auth0ClientSecret
  }
}
