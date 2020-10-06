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
      "Auth0__GrantType" = "client_credentials"

      #UI AUTH0
      "ENVIRONMENT_AUTH_AUTHORITY" = "https://qa-sapienceanalytics.auth0.com"
      "ENVIRONMENT_AUTH_AUDIENCE" = "https://api.sapienceanalytics.com"
      "ENVIRONMENT_AUTH_CLIENT_ID" = "ZxBrWiPNzzpjMA2zJep8BxLz9zQCmWDo"
      "ENVIRONMENT_AUTH_SCOPE" = "openid email profile"
      "ENVIRONMENT_VUE_URL"    =  "https://app.qa.sapienceanalytics.com"
      "ENVIRONMENT_ADMIN_URL"  =  "https://manage.qa.sapienceanalytics.com"
      "auth0_alertrules_id"    = "RqqCr8ymt7csKTgDPrX3braxHve0kEhs"
 
      #AUTH0 URI
      "Auth0__PingUri" = "https://qa-sapienceanalytics.auth0.com/test"

      #MANAGEMENT API
      "Auth0__ManagementApiBaseUrl" = "https://qa-sapienceanalytics.auth0.com/"
      "Auth0__ManagementApiAudience" = "https://api.sapienceanalytics.com"
      "Auth0__ManagementApiClientId" = "0ljzI5jQnH9Fx8yQLxWxGdYOVQGRB4DY"

      #Open-API
      "Auth0ManagementApi__BaseUrl"            =   "https://qa-sapienceanalytics.auth0.com"
      "Auth0ManagementApi__Audience"           =   "https://qa-sapienceanalytics.auth0.com/api/v2/"
      "Auth0ManagementApi__ClientId"           =   "0ljzI5jQnH9Fx8yQLxWxGdYOVQGRB4DY"
      "Auth0ManagementApi__OpenApiAudience"    =   "https://sapience-lab-us-qa.developer.azure-api.net"

  }
}
