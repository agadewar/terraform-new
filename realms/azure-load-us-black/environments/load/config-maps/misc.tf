resource "kubernetes_config_map" "misc" {
  metadata {
    name      = "misc"
    namespace = local.namespace
  }

  data = {
      "ENVIRONMENT_ADMIN_ENABLE_INTEGRATIONS"  = false
      "ASPNETCORE_ENVIRONMENT" = "Production"
      "ENVIRONMENT_API_URL" = "https://api.load.load.us.azure.sapienceanalytics.com"
      "ENVIRONMENT_ADMIN_URL"  =   "https://manage.load.sapienceanalytics.com"
      "ENVIRONMENT_VUE_URL"      =  "https://app.load.sapienceanalytics.com"
      "ENVIRONMENT_VUE_HELP_URL"    =   "https://help.load.load.us.azure.sapienceanalytics.com"
      "ENVIRONMENT_CANOPY_URL"   =  "https://canopy.load.load.us.azure.sapienceanalytics.com/#/sso?path=%2FSapience"
      "LocalSwagger" = "false"
      "ENVIRONMENT_NAME"         =  "load"
      "ENVIRONMENT_SISENSETYPE"     =  "iframe"
  }
}
