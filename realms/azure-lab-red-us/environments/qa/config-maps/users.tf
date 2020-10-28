resource "kubernetes_config_map" "users" {
  metadata {
    name      = "users"
    namespace = local.namespace
  }

  data = {
      "AzureServiceBus__UseAzureServiceBus"    =  true
      "AzureServiceBus__EntityPath"            = "sapience-admin-users-created"
      "AzureServiceBus__Endpoint"              = "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=x9D7XYbxSiMMVssulaXMBn4Q12u7SEHX1pqAkAToGJQ="
      "AzureServiceBus__EditEntityPath"        = "sapience-admin-users-updated"
      "AzureServiceBus__EditEndpoint"          = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=1f8hCZFMPffFG7TUtv+JWMV94F+RgY1I3dgmlRh3xKc="
      "AzureServiceBus__DeleteEntityPath"      = "sapience-admin-users-deleted"
      "AzureServiceBus__DeleteEndpoint"        = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=dOB3YaQvCn6JTveBMen29pr9Ugk9o3h3X50tYGiI6aw="

  }
}
