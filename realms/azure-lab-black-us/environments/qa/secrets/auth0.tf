resource "kubernetes_secret" "auth0" {
  metadata {
    name = "auth0"
    namespace = local.namespace
  }

  data = {
      alertrules_secret = var.auth0_alertrules_secret
      alertrules_clientid = var.auth0_alertrules_clientid
      secret =  var.auth0_secret
      auth0clientsecret = var.sisense_auth0clientsecret
  }
}
