resource "kubernetes_config_map" "apim" {
  metadata {
    name      = "apim"
    namespace = local.namespace
  }

  data = {
    #APIM Open-API
      "ApimConfiguration__AccessToken"    = "SharedAccessSignature integration&202012031109&27HYlqmGpz768l/ZJo40n9mgHa6Hi7epo857uZmaaeGgMov7eF3M5Bj1HxX6PCe2AkftmOX2UpRKj32I/gylvg=="
      "ApimConfiguration__AzureApiUri"    = "https://sapience-lab-us-dev.management.azure-api.net"
      "ApimConfiguration__HomeUrl"        = "https://sapience-lab-us-dev.developer.azure-api.net"
      "ApimConfiguration__ResourceGroup"  = var.resource_group_name
      "ApimConfiguration__ServiceName"    = "sapience-lab-us-dev"
      "ApimConfiguration__SubscriptionId" = var.subscription_id
      "ApimConfiguration__ClientId"       = "nHCfXevT0sYIlyPdKKv4ZMcH8jFPsZPn"
      "ApimConfiguration__Authority"      = "https://dev-piin5umt.auth0.com"
      
  }
}
