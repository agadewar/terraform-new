resource "kubernetes_config_map" "apim" {
  metadata {
    name      = "apim"
    namespace = local.namespace
  }

  data = {
    #APIM Open-API
      "ApimConfiguration__AzureApiUri"    = "https://sapience-lab-eu-dev.management.azure-api.net"
      "ApimConfiguration__HomeUrl"        = "https://sapience-lab-eu-dev.developer.azure-api.net"
      "ApimConfiguration__ResourceGroup"  = var.resource_group_name
      "ApimConfiguration__ServiceName"    = "sapience-lab-eu-dev"
      "ApimConfiguration__SubscriptionId" = var.subscription_id
      "ApimConfiguration__ClientId"       = "mDphdtJzZc5agGu5Nq055QAIA0xKw2hd"
      "ApimConfiguration__Authority"      = "https://dev-piin5umt.auth0.com"
      
  }
}
