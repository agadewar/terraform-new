resource "kubernetes_config_map" "users" {
  metadata {
    name      = "users"
    namespace = local.namespace
  }

  data = {
      "AzureServiceBus__UseAzureServiceBus"      =  true
      "AzureServiceBus__EntityPath"              = "sapience-admin-users-created"
      "AzureServiceBus__Endpoint"                = "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=pU/3MPo29mnx9B7eoxh0D4IGO7UpxqMFmhsnXtAmTAQ="
      "AzureServiceBus__EditEntityPath"          = "sapience-admin-users-updated"
      "AzureServiceBus__EditEndpoint"            = "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=uMRxh0FkdvxoMc0uPguwrBoJHNh/1wiRZLOPcbu+MfM="
      "AzureServiceBus__DeleteEntityPath"        = "sapience-admin-users-deleted"
      "AzureServiceBus__DeleteEndpoint"          = "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=PeAGpUP3G2TrPI/7s/V2KePGQbmalWfFeDtirS1nKbE="
      "AzureServiceBus__DeletedUsersEndPoint"    = "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=e7RAJ4FN7d0fLTr/lwkORZHEtIfOA6/zy+IEQQGXBNk="
      "AzureServiceBus__DeletedUsersEntityPath"  = "sapience-admin-users-deleted"
  }
}
