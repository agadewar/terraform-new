resource "kubernetes_config_map" "identity_provider" {
  metadata {
    name      = "identity"
    namespace = local.namespace
  }

  data = {

      #IDENTITY PROVIDER
      "Authorization__IdentityProvider" = "auth0"

      #AUTH0
      "Authorization__Auth0__Authority"  = "https://qa-sapienceanalytics.auth0.com/"
      "Authorization__Auth0__Audience"   = "https://api.sapienceanalytics.com"
      "Authorization__Auth0__ClientId"   = "ZxBrWiPNzzpjMA2zJep8BxLz9zQCmWDo"
      "Authorization__Auth0__Connection" = "Username-Password-Authentication"
      "Authorization__Ping__Audience"    = "https://api.sapienceanalytics.com/activities"
      "Authorization__Ping__Authority"   = "https://auth.pingone.com/568541f6-bc62-4fdd-b8f4-9f919a2ff4aa/as"

      #PING
      "ENVIRONMENT_AUTH_MODE"            = "auth0"
      "Authorization__Ping__Authority"   = "https://auth.pingone.com/568541f6-bc62-4fdd-b8f4-9f919a2ff4aa/as"
      "Authorization__Ping__Audience"    = "https://api.sapienceanalytics.com/activities"
      "ENVIRONMENT_PING_AUTH_SCOPE"      = "activity openid profile email"
      "ENVIRONMENT_PING_AUTH_AUDIENCE"  =  "https://api.sapienceanalytics.com/activities"
      "ENVIRONMENT_PING_AUTH_AUTHORITY" =  "https://auth.pingone.com/568541f6-bc62-4fdd-b8f4-9f919a2ff4aa/as"
      "ENVIRONMENT_PING_AUTH_CLIENT_ID" = "ee790486-8e19-4339-967c-0e8b7a23f03d"
  }
}
