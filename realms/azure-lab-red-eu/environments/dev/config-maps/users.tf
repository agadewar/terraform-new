resource "kubernetes_config_map" "users" {
  metadata {
    name      = "users"
    namespace = local.namespace
  }

  data = {
      "AzureServiceBus__UseAzureServiceBus"      =  true
      "AzureServiceBus__EntityPath"              =  "sapience-admin-users-created"
      "AzureServiceBus__Endpoint"                =  "Endpoint=sb://sapience-lab-eu-dev.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=uAyfQQRRJiyGDDw16SEpNideMyE9r5zGakbOrbPf/Is=;"
      "AzureServiceBus__EditEntityPath"          =  "sapience-admin-users-updated"
      "AzureServiceBus__EditEndpoint"            =  "Endpoint=sb://sapience-lab-eu-dev.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=/6yoEBHUmSPSKvH9UibZhqz0nlL8lBoXwGNHIqzMl5c=;"
      "AzureServiceBus__DeleteEntityPath"        =  "sapience-admin-users-deleted"
      "AzureServiceBus__DeleteEndpoint"          =  "Endpoint=sb://sapience-lab-eu-dev.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=N7U9mVBlvjv4E4GhDyWkqDxxrXJhbCURFEW4QLIoo9k=;"
      "AzureServiceBus__DeletedUsersEndPoint"    =  "Endpoint=sb://sapience-lab-eu-dev.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=wi0T3iamELCeA9ekczpALDMKRBQUmp1AGHeC59w8Fso=;"
      "AzureServiceBus__DeletedUsersEntityPath"  =  "sapience-admin-users-deleted"
      "AzureServiceBus__DeactivateEndpoint"      =  "Endpoint=sb://sapience-lab-eu-dev.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=woFV2HY5IX8B9DaSXqWGmawgDq1arXUu9KUhRtp760A=;"
      "AzureServiceBus__ActivateEndpoint"        =  "Endpoint=sb://sapience-lab-eu-dev.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=+YT+nlH1b0beV4ETCoOYF+3SQoOMHPHUXRsxDsK0wyU=;"
      "AzureServiceBus__TeamCreatedConnection"   =  "Endpoint=sb://sapience-lab-eu-dev.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=SB+mct+pEGB4v2tgZHLHVjUoRfs6h4hRoUgb+nKr7z8=;"
      "TeamCreatedConnection"                    =  "Endpoint=sb://sapience-lab-eu-dev.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=SB+mct+pEGB4v2tgZHLHVjUoRfs6h4hRoUgb+nKr7z8=;"
      "TeamDeletedConnection"                    =  "Endpoint=sb://sapience-lab-eu-dev.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=IlvVzcozKpHzufCV/OUQKgEKvAmcuyCNyB/wbJyEwGE=;"
      "TeamUpdatedConnection"                    =  "Endpoint=sb://sapience-lab-eu-dev.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=2FpK+DYotik1rCttQFcyLd7ANJTmOZq9PCCdLdpTK4A=;"
  }
}