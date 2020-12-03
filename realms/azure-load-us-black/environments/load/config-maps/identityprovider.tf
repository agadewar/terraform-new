resource "kubernetes_config_map" "identity_provider" {
  metadata {
    name      = "identity"
    namespace = local.namespace
  }

  data = {

      #IDENTITY PROVIDER
      "Authorization__IdentityProvider" = "Auth0"

      #AUTH0
      "Authorization__Auth0__Authority"  = "https://sapience-load-us-load.auth0.com/"
      "Authorization__Auth0__Audience"   = "https://api.sapienceanalytics.com"
      "Authorization__Auth0__ClientId"   = "NJa0UdhJ8v9XqNHz8jroF7dS2QCr0Zm0"
      "Authorization__Auth0__Connection" = "Username-Password-Authentication"
      
      #PING
      "Authorization__Ping__Authority"   = ""
      "Authorization__Ping__Audience"    = "https://api.sapienceanalytics.com/activities"
  }
}
