resource "kubernetes_config_map" "apim" {
  metadata {
    name      = "apim"
    namespace = local.namespace
  }

  data = {
    #APIM Open-API
      "ApimConfiguration__AzureApiUri"    = "https://sapience-prod-us-prod.management.azure-api.net"
      "ApimConfiguration__HomeUrl"        = "https://sapience-prod-us-prod.developer.azure-api.net"
      "ApimConfiguration__ResourceGroup"  = var.resource_group_name
      "ApimConfiguration__ServiceName"    = "sapience-prod-us-prod"
      "ApimConfiguration__SubscriptionId" = var.subscription_id
      "ApimConfiguration__ClientId"       = "DtUve4ZspmZAbbrYYKdBGm3dvjqz16AO"
      "ApimConfiguration__Authority"      = "https://sapience-prod-us-prod.auth0.com"
      
  }
}
