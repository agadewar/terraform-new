resource "kubernetes_config_map" "misc" {
  metadata {
    name      = "misc"
    namespace = local.namespace
  }

  data = {
      "ENVIRONMENT_ADMIN_ENABLE_INTEGRATIONS"  = true
      "ASPNETCORE_ENVIRONMENT"                 =   "Production"
      "ENVIRONMENT_API_URL"                    =   "https://api.prep.prep.us.azure.sapienceanalytics.com"
      "ENVIRONMENT_VUE_URL"                    =   "https://app.prep.sapienceanalytics.com"
      "ENVIRONMENT_ADMIN_URL"                  =   "https://manage.prep.sapienceanalytics.com"
      "LocalSwagger"                           =   "false"
      "ENVIRONMENT_VUE_HELP_URL"               =   "https://help.prep.sapienceanalytics.com"
      "ENVIRONMENT_CANOPY_URL"                 =   "https://canopy.prep.prep.us.azure.sapienceanalytics.com/#/sso?path=%2FSapience"
      "ENVIRONMENT_CANOPY_V3_URL"              =   "https://canopyv3.prep.prep.us.azure.sapienceanalytics.com/#/sso?path=%2FSapience"
      "MicroserviceUrls__AdminSettingBaseUrl"  =   "https://api.prep.sapienceanalytics.com/admin/settings/"
      "ENVIRONMENT_NAME"                       =   "prep"
      "ENVIRONMENT_SISENSETYPE"                =   "js"
      "ENVIRONMENT_ENABLE_ADMIN_REPORTS"       =  true
      "ENVIRONMENT_ENABLE_ADMIN_DASHBOARD"     =  true
      "ENVIRONMENT_ENABLE_INTEGRATION_MONITOR_CYCLE_TILE" =  false
      "ENVIRONMENT_ENABLE_OOO"                            =  false
  }
}
