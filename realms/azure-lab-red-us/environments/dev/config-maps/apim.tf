resource "kubernetes_config_map" "apim" {
  metadata {
    name      = "apim"
    namespace = local.namespace
  }

  data = {
    #APIM Open-API
      "ApimConfiguration__AzureApiUri"    = "https://sapience-lab-us-dev.management.azure-api.net"
      "ApimConfiguration__HomeUrl"        = "https://sapience-lab-us-dev.developer.azure-api.net"
      "ApimConfiguration__ResourceGroup"  = var.resource_group_name
      "ApimConfiguration__ServiceName"    = "sapience-lab-us-dev"
      "ApimConfiguration__SubscriptionId" = var.subscription_id
      "ApimConfiguration__ClientId"       = "nHCfXevT0sYIlyPdKKv4ZMcH8jFPsZPn"
      "ApimConfiguration__Authority"      = "https://login.dev.lab.sapienceanalytics.com"
      
  }
}
