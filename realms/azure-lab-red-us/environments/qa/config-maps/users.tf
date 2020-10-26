resource "kubernetes_config_map" "users" {
  metadata {
    name      = "users"
    namespace = local.namespace
  }

  data = {
      "AzureServiceBus__UseAzureServiceBus"    =  true
      "AzureServiceBus__EntityPath"            = "sapience-admin-users-created"
      "AzureServiceBus__Endpoint"              = "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=x9D7XYbxSiMMVssulaXMBn4Q12u7SEHX1pqAkAToGJQ="
      "AzureServiceBus__EditEndpoint"          =  ""
      "AzureServiceBus__EditEntityPath"        =  ""
      "AzureServiceBus__DeleteEndpoint"        =  ""
      "AzureServiceBus__DeleteEntityPath"      =  ""

  }
}
