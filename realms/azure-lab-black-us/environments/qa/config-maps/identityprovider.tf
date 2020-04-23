resource "kubernetes_config_map" "identity_provider" {
  metadata {
    name      = "identity"
    namespace = local.namespace
  }

  data = {

      #IDENTITY PROVIDER
      "Authorization__IdentityProvider" = "Auth0"

      #AUTH0
      "Authorization__Auth0__Authority"  = "https://qa-sapienceanalytics.auth0.com/"
      "Authorization__Auth0__Audience"   = "https://api.sapienceanalytics.com"
      "Authorization__Auth0__ClientId"   = "ZxBrWiPNzzpjMA2zJep8BxLz9zQCmWDo"
      "Authorization__Auth0__Connection" = "Username-Password-Authentication"

      #PING
      "Authorization__Ping__Authority"   = "https://auth.pingone.com/c9db5466-67e3-448d-adaf-a7881a39709b/as"
      "Authorization__Ping__Audience"    = "https://api.sapienceanalytics.com/activities"
  }
}
