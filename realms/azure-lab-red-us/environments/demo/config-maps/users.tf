resource "kubernetes_config_map" "users" {
  metadata {
    name      = "users"
    namespace = local.namespace
  }

  data = {
      "AzureServiceBus__UseAzureServiceBus"      =  false
      "AzureServiceBus__EntityPath"              = "sapience-admin-users-created"
      "AzureServiceBus__Endpoint"                = "Endpoint=sb://sapience-lab-us-demo.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=C1jCY7iv2MNAQTyseqdZLeAFNLFILXsapvnNJ4xP7Qc="
      "AzureServiceBus__EditEntityPath"          = "sapience-admin-users-updated"
      "AzureServiceBus__EditEndpoint"            = "Endpoint=sb://sapience-lab-us-demo.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=UxCI+/JDBtT0rx7jB8af0XLkQRY4J2D0fS+6l7mzekE="
      "AzureServiceBus__DeleteEntityPath"        = "sapience-admin-users-deleted"
      "AzureServiceBus__DeleteEndpoint"          = "Endpoint=sb://sapience-lab-us-demo.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=VaCNsnPSvUGW6o2EzxYH8RQxn4TQuZursIVncP3bnOY="
      "AzureServiceBus__DeletedUsersEndPoint"    = "Endpoint=sb://sapience-lab-us-demo.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=C6j0bHH+E1xWeWWekjrbZd7QKFyjHuixO/lu35b2AtQ=;EntityPath=sapience-admin-users-deleted"
      "AzureServiceBus__DeletedUsersEntityPath"  = "sapience-admin-users-deleted"
  }
}
