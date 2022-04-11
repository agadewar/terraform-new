resource "kubernetes_config_map" "misc" {
  metadata {
    name      = "misc"
    namespace = local.namespace
  }

  data = {
      "ENVIRONMENT_ADMIN_ENABLE_INTEGRATIONS"  = true
      "ASPNETCORE_ENVIRONMENT"                 =  "Development"
      "ENVIRONMENT_API_URL"                    =  "https://api.dev.lab.us.azure.sapienceanalytics.com"
      "LocalSwagger"                           =  "false"
      "API_URL"                                =  "http://sapience-app-alerts/alertrules/company/eval"
      "MicroserviceUrls__AdminSettingBaseUrl"  =  "https://api.dev.sapienceanalytics.com/admin/settings/"
      "EnableNewGenerationEngine"              = true

      #UI

      "ENVIRONMENT_VUE_URL"                  =  "https://app.dev.sapienceanalytics.com"
      "ENVIRONMENT_ADMIN_URL"                =  "https://manage.dev.sapienceanalytics.com"
      "ENVIRONMENT_VUE_HELP_URL"             =  "https://help.dev.lab.us.azure.sapienceanalytics.com"
      "ENVIRONMENT_CANOPY_URL"               =  "https://canopy.dev.lab-black.us.azure.sapienceanalytics.com/#/sso?path=%2FSapience"
      "ENVIRONMENT_CANOPY_V3_URL"            =  "https://canopyv3.dev.lab-black.us.azure.sapienceanalytics.com/#/sso?path=%2FSapience"
      "ENVIRONMENT_NAME"                     =  "dev"
      "ENVIRONMENT_SISENSETYPE"              =  "js"
      "ENVIRONMENT_ENABLE_ADMIN_REPORTS"     =  true
      "ENVIRONMENT_ENABLE_ADMIN_DASHBOARD"   =  true
<<<<<<< HEAD
      "ENVIRONMENT_SWITCH_SISENSE_TO_DB"     =  true
      "ENVIRONMENT_SISENSE_DATASOURCE_NAME"  =  "Dev"

      
=======
      "ENVIRONMENT_SWITCH_SISENSE_TO_DB"                  =  false
      "ENVIRONMENT_SISENSE_DATASOURCE_NAME"               =  "Dev"
>>>>>>> e94c52f251193600a785751682d0849fa9c4b4b2
  }
}
