resource "kubernetes_config_map" "misc" {
  metadata {
    name      = "misc"
    namespace = local.namespace
  }

  data = {
      "ASPNETCORE_ENVIRONMENT"     =   "Production"
      "ENVIRONMENT_API_URL"        =   "https://api.prod.prod.us.azure.sapienceanalytics.com"
      "ENVIRONMENT_VUE_URL"        =   "https://app.dev.sapienceanalytics.com"
      "ENVIRONMENT_ADMIN_URL"      =   "https://manage.dev.sapienceanalytics.com"
      "LocalSwagger"               =   "false"
      "ENVIRONMENT_VUE_HELP_URL"   =   "https://help.sapienceanalytics.com"
  }
}
