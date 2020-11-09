resource "kubernetes_config_map" "misc" {
  metadata {
    name      = "misc"
    namespace = local.namespace
  }

  data = {
      "ASPNETCORE_ENVIRONMENT"     =   "Production"
      "ENVIRONMENT_API_URL"        =   "https://api.prod.prod.us.azure.sapienceanalytics.com"
      "ENVIRONMENT_VUE_URL"        =   "https://app.sapienceanalytics.com"
      "ENVIRONMENT_ADMIN_URL"      =   "https://manage.sapienceanalytics.com"
      "LocalSwagger"               =   "false"
      "ENVIRONMENT_VUE_HELP_URL"   =   "https://help.sapienceanalytics.com"
      "ENVIRONMENT_CANOPY_URL"     =  "https://canopy.prod.prod.us.azure.sapienceanalytics.com/#/sso?path=%2FSapience"
      "ENVIRONMENT_NAME"           =  "prod"
      "ENVIRONMENT_SISENSETYPE"    =  "js"
  }
}
