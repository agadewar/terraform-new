resource "kubernetes_config_map" "users" {
  metadata {
    name      = "users"
    namespace = local.namespace
  }

  data = {
      "AzureServiceBus__UseAzureServiceBus"      =  true
      "AzureServiceBus__EntityPath"              = "sapience-admin-users-created"
      "AzureServiceBus__Endpoint"                = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=jEcxjwnTChnuMisdsw7xgBUIANE+Kris1IA2Urxmndg="
      "AzureServiceBus__EditEntityPath"          = "sapience-admin-users-updated"
      "AzureServiceBus__EditEndpoint"            = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=sUJBkqJpE8ouK0eagOSsigPA59ifpRPKbf032bXHRKo="
      "AzureServiceBus__DeleteEntityPath"        = "sapience-admin-users-deleted"
      "AzureServiceBus__DeleteEndpoint"          = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=73LAxHOhxt4vPv91vUxDr5nq5djY0Nftsk3yGzQqs1A="
      "AzureServiceBus__DeletedUsersEndPoint"    = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=kdbQ/M3CZzEIagskM8/JetX3LMuePgnF2xbcYgfIGAE=;"
      "AzureServiceBus__DeletedUsersEntityPath"  = "sapience-admin-users-deleted"
      "TeamCreatedConnection"                    = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=leQbckeauyGd+EWoSFu6lDpUKp6iV8f+iGwpF/ilQIs=;"
      "TeamDeletedConnection"                    = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=publish;SharedAccessKey=4v0D0eo8siBNMRngjEi/95pyG6GyclXJn7BE+4Mklak=;"
      "TeamUpdatedConnection"                    = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=LGu3q9Ex0CThsy8k1aMTCAcS6blWHMd3/riJhs4WZnE=;"
  }
}