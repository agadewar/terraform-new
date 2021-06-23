resource "kubernetes_config_map" "auth0" {
  metadata {
    name      = "auth0"
    namespace = local.namespace
  }

  data = {
      #MAIN AUTH0
      "Auth0__Authority" = "https://sapience-lab-eu-dev.eu.auth0.com"
      "Auth0__Audience" = "https://api.sapienceanalytics.com"
      "Auth0__ClientId" = "BJ6q2sxMtSYvYwCpWteqFyKpoaRc282w"
      "Auth0__Connection" = "Username-Password-Authentication"
      "Auth0__GrantType" = "client_credentials"

      #UI AUTH0
      "ENVIRONMENT_ADMIN_URL"      = "https://manage.dev.eu.sapienceanalytics.com"
      "ENVIRONMENT_AUTH_AUTHORITY" = "https://sapience-lab-eu-dev.eu.auth0.com"
      "ENVIRONMENT_AUTH_AUDIENCE" = "https://api.sapienceanalytics.com"
      "ENVIRONMENT_AUTH_CLIENT_ID" = "BJ6q2sxMtSYvYwCpWteqFyKpoaRc282w"
      "ENVIRONMENT_AUTH_SCOPE" = "openid email profile"
      "ENVIRONMENT_VUE_URL" = "https://app.dev.lab-eu.sapienceanalytics.com"

      #AUTH0 URI
      "Auth0__PingUri" = "https://sapience-lab-eu-dev.eu.auth0.com/test"

      #MANAGEMENT API
      "Auth0__ManagementApiBaseUrl" = "https://sapience-lab-eu-dev.eu.auth0.com"
      "Auth0__ManagementApiAudience" = "https://sapience-lab-eu-dev.eu.auth0.com/api/v2/"
      "Auth0__ManagementApiClientId" = "5BIiNYJDqLcNet95rtK5VaQh9IC9Jqa5"

      #Open-API
      "Auth0ManagementApi__BaseUrl"  = "https://sapience-lab-eu-dev.eu.auth0.com"
      "Auth0ManagementApi__Audience" = "https://sapience-lab-eu-dev.eu.auth0.com/api/v2/"
      "Auth0ManagementApi__ClientId" = "5BIiNYJDqLcNet95rtK5VaQh9IC9Jqa5"
      "Auth0ManagementApi__OpenApiAudience" = "https://sapience-lab-eu-dev.developer.azure-api.net"

      # POST API NOTIFICATION
      "auth0_alertrules_id" = "Vm3QDRujqkNdmfqKnNdUnFUGz7bTgA2h"
  }
}
