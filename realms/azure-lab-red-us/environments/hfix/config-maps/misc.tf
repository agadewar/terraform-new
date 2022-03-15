resource "kubernetes_config_map" "misc" {
  metadata {
    name      = "misc"
    namespace = local.namespace
  }

  data = {
      "ENVIRONMENT_ADMIN_ENABLE_INTEGRATIONS"  = true
      "ASPNETCORE_ENVIRONMENT"                 =  "Development"
      "ENVIRONMENT_API_URL"                    =  "https://api.hfix.lab.us.azure.sapienceanalytics.com"
      "LocalSwagger"                           =  "false"
      "API_URL"                                =  "http://sapience-app-alerts/alertrules/company/eval"
      "MicroserviceUrls__AdminSettingBaseUrl"  =  "https://api.hfix.sapienceanalytics.com/admin/settings/"
      "EnableNewGenerationEngine"              = true

      #UI
      "ENVIRONMENT_VUE_URL"                    =  "https://app.hfix.sapienceanalytics.com"
      "ENVIRONMENT_ADMIN_URL"                  =  "https://manage.hfix.sapienceanalytics.com"
      "ENVIRONMENT_VUE_HELP_URL"               =  "https://help.hfix.lab.us.azure.sapienceanalytics.com" 
      "ENVIRONMENT_CANOPY_URL"                 =  "https://canopyv3.qa.lab.us.azure.sapienceanalytics.com/#/sso?path=%2FSapience"
      "ENVIRONMENT_CANOPY_V3_URL"              =  "https://canopyv3.qa.lab-black.us.azure.sapienceanalytics.com/#/sso?path=%2FSapience"
      "ENVIRONMENT_NAME"                       =  "hfix"
      "ENVIRONMENT_SISENSETYPE"                =  "js"
      "ENVIRONMENT_ENABLE_ADMIN_REPORTS"       =  true
      "ENVIRONMENT_ENABLE_ADMIN_DASHBOARD"     =  true
      "ENVIRONMENT_ENABLE_INTEGRATION_MONITOR_CYCLE_TILE" =  true
      "ENVIRONMENT_ENABLE_OOO"                            =  true
  }
}
