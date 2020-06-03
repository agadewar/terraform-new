resource "kubernetes_config_map" "ping" {
  metadata {
    name      = "ping"
    namespace = local.namespace
  }

  data = {
      "Authorization__IdentityProvider"    =  "Ping"
      "Authorization__Ping__Audience"      =  "https://api.sapienceanalytics.com/activities"
      "Authorization__Ping__Authority"     =  "https://auth.pingone.com/b0d58849-974f-4b71-8247-ea75ed6936d0/as"
      "ENVIRONMENT__AUTH__AUDIENCE"          =  "https://api.sapienceanalytics.com/activities"
      "ENVIRONMENT__AUTH__AUTHORITY"         =  "https://auth.pingone.com/b0d58849-974f-4b71-8247-ea75ed6936d0c/as"
      "ENVIRONMENT__AUTH__CLIENT_ID"         =  "d60abee0-273a-4fd4-a116-d2c791bd1800"
      "ENVIRONMENT__AUTH__SCOPE"             =  "openid email profile"
  }
}