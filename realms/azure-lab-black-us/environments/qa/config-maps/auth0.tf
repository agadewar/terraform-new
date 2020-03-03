resource "kubernetes_config_map" "auth0" {
  metadata {
    name      = "auth0"
    namespace = local.namespace
  }

  data = {
      #MAIN AUTH0
      "Auth0__Authority" = "https://qa-sapienceanalytics.auth0.com/"
      "Auth0__Audience" = "https://api.sapienceanalytics.com"
      "Auth0__ClientId" = "ZxBrWiPNzzpjMA2zJep8BxLz9zQCmWDo"
      "Auth0__Connection" = "Username-Password-Authentication"

      #UI AUTH0
      "ENVIRONMENT_AUTH_AUTHORITY" = "https://qa-sapienceanalytics.auth0.com/"
      "ENVIRONMENT_AUTH_AUDIENCE" = "https://api.sapienceanalytics.com"
      "ENVIRONMENT_AUTH_CLIENT_ID" = "ZxBrWiPNzzpjMA2zJep8BxLz9zQCmWDo"
      "ENVIRONMENT_AUTH_SCOPE" = "openid email profile"

      #AUTH0 URI
      "Auth0__PingUri" = "https://qa-sapienceanalytics.auth0.com/test"

      #MANAGEMENT API
      "Auth0__ManagementApiBaseUrl" = ""
      "Auth0__ManagementApiAudience" = ""
      "Auth0__ManagementApiClientId" = ""
  }
}