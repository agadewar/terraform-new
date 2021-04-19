resource "kubernetes_config_map" "users" {
  metadata {
    name      = "users"
    namespace = local.namespace
  }

  data = {
      "AzureServiceBus__UseAzureServiceBus"      =  true
      "AzureServiceBus__EntityPath"              =  "sapience-admin-users-created"
      "AzureServiceBus__Endpoint"                =  "Endpoint=sb://sapience-lab-us-demo.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=C1jCY7iv2MNAQTyseqdZLeAFNLFILXsapvnNJ4xP7Qc="
      "AzureServiceBus__EditEntityPath"          =  "sapience-admin-users-updated"
      "AzureServiceBus__EditEndpoint"            =  "Endpoint=sb://sapience-lab-us-demo.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=UxCI+/JDBtT0rx7jB8af0XLkQRY4J2D0fS+6l7mzekE="
      "AzureServiceBus__DeleteEntityPath"        =  "sapience-admin-users-deleted"
      "AzureServiceBus__DeleteEndpoint"          =  "Endpoint=sb://sapience-lab-us-demo.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=VaCNsnPSvUGW6o2EzxYH8RQxn4TQuZursIVncP3bnOY="
      "AzureServiceBus__DeletedUsersEndPoint"    =  "Endpoint=sb://sapience-lab-us-demo.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=C6j0bHH+E1xWeWWekjrbZd7QKFyjHuixO/lu35b2AtQ="
      "AzureServiceBus__DeletedUsersEntityPath"  =  "sapience-admin-users-deleted"
      "AzureServiceBus__DeactivateEndpoint"      =  "Endpoint=sb://sapience-lab-us-demo.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=2cZJDhs9y0jZkNuEej5UrJCoEIrjVpmR7N4gGpa5Po8="
      "AzureServiceBus__ActivateEndpoint"        =  "Endpoint=sb://sapience-lab-us-demo.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=GdZjBhXXLvDcNoYz9L9SU7u45CtTxA9BfwwEQb7+3LE="
      "AzureServiceBus__TeamCreatedConnection"   =  "Endpoint=sb://sapience-lab-us-demo.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=1eDGhk9qginL+3QCP8rjUDD+RRzMvDRiTcLTbMPh6C0=;"
      "TeamDeletedConnection"                    =  "Endpoint=sb://sapience-lab-us-demo.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=IzcL1CHxRiiSIj69le7kN/pxGt5YZGXWxQjOIbsMxOM=;"
      "TeamUpdatedConnection"                    =  "Endpoint=sb://sapience-lab-us-demo.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=+wLPT9rSQO3Y2r8r+nPmB9RHT5uB/B7QdJWJnLPB3Y8=;"
  }
}
