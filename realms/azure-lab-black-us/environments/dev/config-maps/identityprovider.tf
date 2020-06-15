resource "kubernetes_config_map" "identity_provider" {
  metadata {
    name      = "identity"
    namespace = local.namespace
  }

  data = {

      #IDENTITY PROVIDER
      #"Authorization__IdentityProvider"    = "auth0"
      "Authorization__IdentityProvider"    =  "Ping"

      #AUTH0
      "Authorization__Auth0__Authority"  = "https://login.dev.lab.sapienceanalytics.com/"
      "Authorization__Auth0__Audience"   = "https://api.sapienceanalytics.com"
      "Authorization__Auth0__ClientId"   = "d60abee0-273a-4fd4-a116-d2c791bd1800"
      "Authorization__Auth0__Connection" = "Username-Password-Authentication"

      #PING
      "Authorization__Ping__Audience"      =  "https://api.sapienceanalytics.com/activities"
      "Authorization__Ping__Authority"     =  "https://auth.pingone.com/b0d58849-974f-4b71-8247-ea75ed6936d0/as"

      "ENVIRONMENT_AUTH_MODE"              =  "ping"
      "ENVIRONMENT_PING_AUTH_AUTHORITY"    =  "https://auth.pingone.com/b0d58849-974f-4b71-8247-ea75ed6936d0/as"
      "ENVIRONMENT_PING_AUTH_AUDIENCE"     =  "https://api.sapienceanalytics.com/activities"
      "ENVIRONMENT_PING_AUTH_CLIENT_ID"    =  "d60abee0-273a-4fd4-a116-d2c791bd1800"
      "ENVIRONMENT_PING_AUTH_SCOPE"        =  "openid activity"

  }
}
