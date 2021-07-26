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

      #Admin_service_bus

      "AzureServiceBus__DepartmentUpdatedEntityPath" = "sapience-admin-departments-updated"
      "AzureServiceBus__DepartmentUpdatedConnection" = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=wJwU2RjRtnD1bstPr1WDUFzHcWG/IvceyXQ/i5gvrLA=;"
      "AzureServiceBus__DepartmentDeletedEntityPath" = "sapience-admin-departments-deleted"
      "AzureServiceBus__DepartmentDeletedConnection" = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=V+ajh//jlNVYYM1+75uK7FTsbouY9k7gIzEgNy2E4Jo=;"
      "AzureServiceBus__ActivityUpdatedEntityPath"   = "sapience-admin-activity-updated"
      "AzureServiceBus__ActivityUpdatedConnection"   = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=PsDVzfC9ZdDqURAjWx3PtG93GYFuJSfhhBMvyXU8a78=;"
      "AzureServiceBus__ActivityDeletedEntityPath"   = "sapience-admin-activity-deleted"
      "AzureServiceBus__ActivityDeletedConnection"   = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=Ulx0d2nlMIu4ozRXQHCZ+gkd8LN56U6kBaBtiD6oV2k=;" 
  }
}
