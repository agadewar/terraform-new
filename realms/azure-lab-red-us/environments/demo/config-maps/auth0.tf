resource "kubernetes_config_map" "auth0" {
  metadata {
    name      = "auth0"
    namespace = local.namespace
  }

  data = {
      #MAIN AUTH0
      "Auth0__Authority" = "https://login.demo.lab.sapienceanalytics.com/"
      "Auth0__Audience" = "https://api.sapienceanalytics.com"
      "Auth0__ClientId" = "ot1zP3J0CaNqNcX1EMoy3ob3jLvlTLnc"
      "Auth0__Connection" = "Username-Password-Authentication"
      "Auth0__GrantType" = "client_credentials"

      #UI AUTH0
      "ENVIRONMENT_ADMIN_URL"      = "https://manage.demo.sapienceanalytics.com"
      "ENVIRONMENT_AUTH_AUTHORITY" = "https://login.demo.lab.sapienceanalytics.com"
      "ENVIRONMENT_AUTH_AUDIENCE" = "https://api.sapienceanalytics.com"
      "ENVIRONMENT_AUTH_CLIENT_ID" = "ot1zP3J0CaNqNcX1EMoy3ob3jLvlTLnc"
      "ENVIRONMENT_AUTH_SCOPE" = "openid email profile"
      "ENVIRONMENT_VUE_URL" = "https://app.demo.sapienceanalytics.com"

      #Alerts AUTH0
      "alertrules__clientid"   = "WOhe3bLbEEcJidxP7X5zZcXlf4eKHlSC"
      "alertrules__secret"     = "OPAPcsz-oZd8xabFPZIn5sxe9DFOYhlVkMTz2Jflnvz0syBv1sAlrH7PDE2RIgTO"
      
      #AUTH0 URI
      "Auth0__PingUri" = "https://sapience-lab-us-demo.auth0.com/test"

      #MANAGEMENT API
      "Auth0__ManagementApiBaseUrl" = ""
      "Auth0__ManagementApiAudience" = ""
      "Auth0__ManagementApiClientId" = ""

      #Open-API
      "Auth0ManagementApi__BaseUrl"  = "https://sapience-lab-us-demo.auth0.com"
      "Auth0ManagementApi__Audience" = "https://sapience-lab-us-demo.auth0.com/api/v2/"
      "Auth0ManagementApi__ClientId" = "C9YxJfV5kXSQNqryA536Izc0elUQb4nh"
      "Auth0ManagementApi__OpenApiAudience" = "https://sapience-lab-us-demo.developer.azure-api.net"
  }
}
