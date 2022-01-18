resource "kubernetes_config_map" "auth0" {
  metadata {
    name      = "auth0"
    namespace = local.namespace
  }

  data = {
      #MAIN AUTH0
      "Auth0__Authority" = "https://login.prep.sapienceanalytics.com/"
      "Auth0__Audience" = "https://prep.us.prep.sapienceanalytics.com"
      "Auth0__ClientId" = "Z0WJklJErXkHLo1OpGQzWYy6yUf84rFZ"
      "Auth0__Connection" = "Username-Password-Authentication"

      #UI AUTH0
      "ENVIRONMENT_ADMIN_URL"   =  "https://manage.prep.sapienceanalytics.com"
      "ENVIRONMENT_AUTH_AUTHORITY" = "https://login.prep.sapienceanalytics.com"
      "ENVIRONMENT_AUTH_AUDIENCE" = "https://prep.us.prep.sapienceanalytics.com"
      "ENVIRONMENT_AUTH_CLIENT_ID" = "Z0WJklJErXkHLo1OpGQzWYy6yUf84rFZ"
      "ENVIRONMENT_AUTH_SCOPE" = "openid email profile"
      "ENVIRONMENT_VUE_URL"  =  "https://app.sapienceanalytics.com"
      "alertrules__clientid"   = "G38O71G7FuKxRRjexJ9tCtNPVkcq9Bmf"
      "alertrules__secret"     = "rjLj_xTsDzlkxJu32EJvNTD9qgmobp_ZqQbZTh5HqlmWsuaeoqnuRNEOx_ejw6Jw"
      #AUTH0 URI
      "Auth0__PingUri" = "https://login.sapienceanalytics.com/test"

      #MANAGEMENT API
      "Auth0__ManagementApiBaseUrl" = "https://sapience-prep-us-prep.auth0.com"
      "Auth0__ManagementApiAudience" = "https://sapience-prep-us-prep.auth0.com/api/v2/"
      "Auth0__ManagementApiClientId" = "XRkS1SxvtlRhAmMJY0gWZuQ12OjYyY0r"

      #Open-API
      "Auth0ManagementApi__BaseUrl"  = "https://sapience-prep-us-prep.auth0.com"
      "Auth0ManagementApi__Audience" = "https://sapience-prep-us-prep.auth0.com/api/v2/"
      "Auth0ManagementApi__ClientId" = "ZzvhsGz6r6LPbWpw3Gk0Q1dMLNy5mnKL"
      "Auth0ManagementApi__OpenApiAudience" = "https://sapience-prep-us-prep.developer.azure-api.net"
  }
}
