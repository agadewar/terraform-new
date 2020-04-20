resource "kubernetes_config_map" "auth0" {
  metadata {
    name      = "auth0"
    namespace = local.namespace
  }

  data = {
      #MAIN AUTH0
      "Auth0__Authority" = "https://sapience-load-us-load.auth0.com/"
      "Auth0__Audience" = "https://load.us.load.sapienceanalytics.com"
      "Auth0__ClientId" = "ZWLJJ6Tmswh7QSOqkXdYo4GfEVYL686G"
      "Auth0__Connection" = "Username-Password-Authentication"

      #UI AUTH0
      "ENVIRONMENT_AUTH_AUTHORITY" = "https://sapience-load-us-load.auth0.com"
      "ENVIRONMENT_AUTH_AUDIENCE" = "https://load.us.load.sapienceanalytics.com"
      "ENVIRONMENT_AUTH_CLIENT_ID" = "ZWLJJ6Tmswh7QSOqkXdYo4GfEVYL686G"
      "ENVIRONMENT_AUTH_SCOPE" = "openid email profile"

      #AUTH0 URI
      "Auth0__PingUri" = "https://sapience-load-us-load.auth0.com/"

      #MANAGEMENT API
      "Auth0__ManagementApiBaseUrl" = ""
      "Auth0__ManagementApiAudience" = ""
      "Auth0__ManagementApiClientId" = ""
  }
}
