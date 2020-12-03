resource "kubernetes_config_map" "auth0" {
  metadata {
    name      = "auth0"
    namespace = local.namespace
  }

  data = {
      #MAIN AUTH0
      "Auth0__Authority" = "https://sapience-load-us-load.auth0.com/"
      "Auth0__Audience" = "https://api.sapienceanalytics.com"
      "Auth0__ClientId" = "NJa0UdhJ8v9XqNHz8jroF7dS2QCr0Zm0"
      "Auth0__Connection" = "Username-Password-Authentication"

      #UI AUTH0
      "ENVIRONMENT_AUTH_AUTHORITY" = "https://sapience-load-us-load.auth0.com"
      "ENVIRONMENT_AUTH_AUDIENCE" = "https://api.sapienceanalytics.com"
      "ENVIRONMENT_AUTH_CLIENT_ID" = "NJa0UdhJ8v9XqNHz8jroF7dS2QCr0Zm0"
      "ENVIRONMENT_AUTH_SCOPE" = "openid email profile"
      "ENVIRONMENT_ADMIN_URL"  =   "https://manage.load.sapienceanalytics.com"
      "ENVIRONMENT_VUE_URL"      =  "https://app.load.sapienceanalytics.com"
      #Alerts AUTH0
      "alertrules__clientid"   = "jBhtm8wXQPRF2UGI3xXj8G8acRlR5Ua5"
      "alertrules__secret"     = "ne126wo_xn2-uZOW7ZspnydNMyzZ3QF6inznep31Kzz72-MYfPPAj4QLsW6fTVRw"

      #AUTH0 URI
      "Auth0__PingUri" = "https://sapience-load-us-load.auth0.com/"

      #MANAGEMENT API
      "Auth0__ManagementApiBaseUrl" = "https://sapience-load-us-load.auth0.com"
      "Auth0__ManagementApiAudience" = "https://sapience-load-us-load.auth0.com/api/v2/"
      "Auth0__ManagementApiClientId" = "7TQZYoa2oy4HfN4HWHVPu1yAfmxhJSaz"
      "Auth0ManagementApi__OpenApiAudience" = "https://sapience-load-us-load.developer.azure-api.net"

  }
}
