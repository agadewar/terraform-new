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
      "ENVIRONMENT_ADMIN_URL"   =  "https://manage.dev.sapienceanalytics.com"
      "ENVIRONMENT_AUTH_AUTHORITY" = "https://sapience-prod-us-prod.auth0.com"
      "ENVIRONMENT_AUTH_AUDIENCE" = "https://prod.us.prod.sapienceanalytics.com"
      "ENVIRONMENT_AUTH_CLIENT_ID" = "mk3ftdtiPis6dkRv0Sxy6gvFxsjZTs3e"
      "ENVIRONMENT_AUTH_SCOPE" = "openid email profile"
      "ENVIRONMENT_VUE_URL"  =  "https://app.dev.sapienceanalytics.com"
      "alertrules__clientid"   = "wCwqELzQP5ZiGTCkXXfWS7WjWE1xFLk9"
      "alertrules__secret"     = "r7Dq1bJ5GG3qVpeA2g6Ub95HfDCQF7Pv28gTFgQa7U4kU_RABy5el-5pSho4-I0b"
      #AUTH0 URI
      "Auth0__PingUri" = "https://sapience-prod-us-prod.auth0.com/test"

      #MANAGEMENT API
      "Auth0__ManagementApiBaseUrl" = ""
      "Auth0__ManagementApiAudience" = ""
      "Auth0__ManagementApiClientId" = ""
  }
}
