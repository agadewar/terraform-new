resource "kubernetes_config_map" "apim" {
  metadata {
    name      = "apim"
    namespace = local.namespace
  }

  data = {
    #APIM Open-API
      "ApimConfiguration__AzureApiUri"    = "https://sapience-load-us-load.management.azure-api.net"
      "ApimConfiguration__HomeUrl"        = "https://sapience-load-us-load.developer.azure-api.net"
      "ApimConfiguration__ResourceGroup"  = var.resource_group_name
      "ApimConfiguration__ServiceName"    = "sapience-load-us-load"
      "ApimConfiguration__SubscriptionId" = var.subscription_id
      "ApimConfiguration__ClientId"       = "YgYR1ywX1QtIAhkMo6YuU7U79GlUTiSZ"
      "ApimConfiguration__Authority"      = "https://sapience-load-us-load.auth0.com"
      
  }
}
