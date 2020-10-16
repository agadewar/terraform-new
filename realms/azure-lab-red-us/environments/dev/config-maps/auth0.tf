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
      "Auth0__GrantType" = "client_credentials"

      #UI AUTH0
      "ENVIRONMENT_ADMIN_URL"      = "https://manage.dev.sapienceanalytics.com"
      "ENVIRONMENT_AUTH_AUTHORITY" = "https://login.dev.lab.sapienceanalytics.com"
      "ENVIRONMENT_AUTH_AUDIENCE" = "https://api.sapienceanalytics.com"
      "ENVIRONMENT_AUTH_CLIENT_ID" = "gEurUe965S21CvJyQtArQ3z8TahgC20K"
      "ENVIRONMENT_AUTH_SCOPE" = "openid email profile"
      "ENVIRONMENT_VUE_URL" = "https://app.dev.sapienceanalytics.com"

      #AUTH0 URI
      "Auth0__PingUri" = "https://login.dev.lab.sapienceanalytics.com/test"

      #MANAGEMENT API
      "Auth0__ManagementApiBaseUrl" = "https://dev-piin5umt.auth0.com"
      "Auth0__ManagementApiAudience" = "https://dev-piin5umt.auth0.com/api/v2/"
      "Auth0__ManagementApiClientId" = "pGmGyQ49XNlCp8gd46a2cbEwC53xX4sj"

      #Open-API
      "Auth0ManagementApi__BaseUrl"  = "https://dev-piin5umt.auth0.com"
      "Auth0ManagementApi__Audience" = "https://dev-piin5umt.auth0.com/api/v2/"
      "Auth0ManagementApi__ClientId" = ""
      "Auth0ManagementApi__OpenApiAudience" = "https://sapience-lab-us-dev.developer.azure-api.net"

      # POST API NOTIFICATION
      "auth0_alertrules_id" = "w6Qfd31Vzgv2b1rfqIj9II5rWnTB7HQv"
  }
}
