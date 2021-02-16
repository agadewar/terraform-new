resource "kubernetes_config_map" "users" {
  metadata {
    name      = "users"
    namespace = local.namespace
  }

  data = {
      "AzureServiceBus__UseAzureServiceBus"      =  true
      "AzureServiceBus__EntityPath"              = "sapience-admin-users-created"
      "AzureServiceBus__Endpoint"                = "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=KzggZ7ksDIiPqA2tBPC4dKhVEyx/tFjbwNOgfScVzzU="
      "AzureServiceBus__EditEntityPath"          = "sapience-admin-users-updated"
      "AzureServiceBus__EditEndpoint"            = "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=uMRxh0FkdvxoMc0uPguwrBoJHNh/1wiRZLOPcbu+MfM="
      "AzureServiceBus__DeleteEntityPath"        = "sapience-admin-users-deleted"
      "AzureServiceBus__DeleteEndpoint"          = "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=PeAGpUP3G2TrPI/7s/V2KePGQbmalWfFeDtirS1nKbE="
      "AzureServiceBus__DeletedUsersEndPoint"    = "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=e7RAJ4FN7d0fLTr/lwkORZHEtIfOA6/zy+IEQQGXBNk="
      "AzureServiceBus__DeletedUsersEntityPath"  = "sapience-admin-users-deleted"
      "TeamCreatedConnection"                    = "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=dbWfJKUm1hSJOOs3AwSXu84FBVx5TV+GNKSqqHyoEJc=;"
      "TeamDeletedConnection"                    = "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=eeYaDbe93jzQXpYqxi0Qkt0EX0q8b58biD3MNkeepAk=;"
      "TeamUpdatedConnection"                    = "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=nRssOd909AmvAVCd7/ycLmZQeViK4a+RSQ2cbpPMA1Q=;"
  }
}
