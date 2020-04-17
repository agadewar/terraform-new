resource "kubernetes_config_map" "auth0" {
  metadata {
    name      = "auth0"
    namespace = local.namespace
  }

  data = {
      #MAIN AUTH0
      "Auth0__Authority" = "https://sapience-prod-us-prod.auth0.com/"
      "Auth0__Audience" = "https://prod.us.prod.sapienceanalytics.com"
      "Auth0__ClientId" = "mk3ftdtiPis6dkRv0Sxy6gvFxsjZTs3e"
      "Auth0__Connection" = "Username-Password-Authentication"

      #UI AUTH0
      "ENVIRONMENT_AUTH_AUTHORITY" = "https://sapience-prod-us-prod.auth0.com"
      "ENVIRONMENT_AUTH_AUDIENCE" = "https://prod.us.prod.sapienceanalytics.com"
      "ENVIRONMENT_AUTH_CLIENT_ID" = "mk3ftdtiPis6dkRv0Sxy6gvFxsjZTs3e"
      "ENVIRONMENT_AUTH_SCOPE" = "openid email profile"

      #AUTH0 URI
      "Auth0__PingUri" = "https://sapience-prod-us-prod.auth0.com/test"

      #MANAGEMENT API
      "Auth0__ManagementApiBaseUrl" = ""
      "Auth0__ManagementApiAudience" = ""
      "Auth0__ManagementApiClientId" = ""
  }
}