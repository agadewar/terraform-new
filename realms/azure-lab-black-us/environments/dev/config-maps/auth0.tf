resource "kubernetes_config_map" "auth0" {
  metadata {
    name      = "auth0"
    namespace = local.namespace
  }

  data = {
      #MAIN AUTH0
      "Auth0__Authority" = "https://login.dev.lab.sapienceanalytics.com/"
      "Auth0__Audience" = "https://api.sapienceanalytics.com"
      "Auth0__ClientId" = "gEurUe965S21CvJyQtArQ3z8TahgC20K"
      "Auth0__Connection" = "Username-Password-Authentication"

      #UI AUTH0
      "ENVIRONMENT_AUTH_AUTHORITY" = "https://login.dev.lab.sapienceanalytics.com/"
      "ENVIRONMENT_AUTH_AUDIENCE" = "https://api.sapienceanalytics.com"
      "ENVIRONMENT_AUTH_CLIENT_ID" = "gEurUe965S21CvJyQtArQ3z8TahgC20K"
      "ENVIRONMENT_AUTH_SCOPE" = "openid email profile"

      #AUTH0 URI
      "Auth0__PingUri" = "https://login.dev.lab.sapienceanalytics.com/test"

      #MANAGEMENT API
      "Auth0__ManagementApiBaseUrl" = "https://dev-piin5umt.auth0.com"
      "Auth0__ManagementApiAudience" = "https://dev-piin5umt.auth0.com/api/v2/"
      "Auth0__ManagementApiClientId" = "pGmGyQ49XNlCp8gd46a2cbEwC53xX4sj"
  }
}