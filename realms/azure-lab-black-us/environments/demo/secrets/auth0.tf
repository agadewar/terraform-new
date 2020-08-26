resource "kubernetes_secret" "auth0" {
  metadata {
    name = "auth0"
    namespace = local.namespace
  }

  data = {
      secret =  var.auth0_secret
      alertrules_clientid = var.auth0_alertrules_clientid
      alertrules_secret = var.auth0_alertrules_secret
      auth0clientsecret = var.sisense_auth0clientsecret
  }
}
