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
      "AzureServiceBus__UpdatedUsersEndpoint"    =  "Endpoint=sb://sapience-lab-us-demo.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=H9CMTIFi0wdKyUc4vmrBMiS6l8oK9IlD9NTnqNCJ1YM=;"
      "AzureServiceBus__UpdatedUsersEntityPath"  =  "sapience-admin-users-updated"
      "AzureServiceBus__TeamCreatedConnection"   =  "Endpoint=sb://sapience-lab-us-demo.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=1eDGhk9qginL+3QCP8rjUDD+RRzMvDRiTcLTbMPh6C0=;"
      "AzureServiceBus__TeamDeletedConnection"   =  "Endpoint=sb://sapience-lab-us-demo.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=IzcL1CHxRiiSIj69le7kN/pxGt5YZGXWxQjOIbsMxOM=;"
      "AzureServiceBus__TeamUpdatedConnection"   =  "Endpoint=sb://sapience-lab-us-demo.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=+wLPT9rSQO3Y2r8r+nPmB9RHT5uB/B7QdJWJnLPB3Y8=;"

      #Admin_service_bus

      "AzureServiceBus__DepartmentUpdatedEntityPath" = "sapience-admin-departments-updated"
      "AzureServiceBus__DepartmentUpdatedConnection" = "Endpoint=sb://sapience-lab-us-demo.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=ZMoK/ypSEFCgYA8G1vZKEbM1b0jzJB1GVKd9GlLbzYQ=;"
      "AzureServiceBus__DepartmentDeletedEntityPath" = "sapience-admin-departments-deleted"
      "AzureServiceBus__DepartmentDeletedConnection" = "Endpoint=sb://sapience-lab-us-demo.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=LjMQkwFBVLPaQ+8mlVIZDeAF6bhfre40mO3o0UdI9Ww=;"
      "AzureServiceBus__ActivityUpdatedEntityPath"   = "sapience-admin-activity-updated"
      "AzureServiceBus__ActivityUpdatedConnection"   = "Endpoint=sb://sapience-lab-us-demo.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=czCF2dzXozH1J+sUdencjg4rZwVLatqx12a1Wfzlv7I=;"
      "AzureServiceBus__ActivityDeletedEntityPath"   = "sapience-admin-activity-deleted"
      "AzureServiceBus__ActivityDeletedConnection"   = "Endpoint=sb://sapience-lab-us-demo.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=pciqvLqYuKx8HqHnhFm6gfkZ/uvLFRsFFAlIj0JTCZw=;"
  }
}
