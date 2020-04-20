resource "kubernetes_config_map" "auth0" {
  metadata {
    name      = "auth0"
    namespace = local.namespace
  }

  data = {
      #MAIN AUTH0
      "Auth0__Authority" = "https://sapience-lab-us-demo.auth0.com/"
      "Auth0__Audience" = "https://api.sapienceanalytics.com"
      "Auth0__ClientId" = "ot1zP3J0CaNqNcX1EMoy3ob3jLvlTLnc"
      "Auth0__Connection" = "Username-Password-Authentication"
      "Auth0__GrantType" = "client_credentials"

      #UI AUTH0
      "ENVIRONMENT_ADMIN_URL"      = "https://manage.dev.sapienceanalytics.com"
      "ENVIRONMENT_AUTH_AUTHORITY" = "https://sapience-lab-us-demo.auth0.com"
      "ENVIRONMENT_AUTH_AUDIENCE" = "https://api.sapienceanalytics.com"
      "ENVIRONMENT_AUTH_CLIENT_ID" = "ot1zP3J0CaNqNcX1EMoy3ob3jLvlTLnc"
      "ENVIRONMENT_AUTH_SCOPE" = "openid email profile"
      "ENVIRONMENT_VUE_URL" = "https://app.dev.sapienceanalytics.com"

      #AUTH0 URI
      "Auth0__PingUri" = "https://sapience-lab-us-demo.auth0.com/test"

      #MANAGEMENT API
      "Auth0__ManagementApiBaseUrl" = ""
      "Auth0__ManagementApiAudience" = ""
      "Auth0__ManagementApiClientId" = ""
  }
}