resource "kubernetes_config_map" "apim" {
  metadata {
    name      = "apim"
    namespace = local.namespace
  }

  data = {
    #APIM Open-API
      "ApimConfiguration__AccessToken"    = "SharedAccessSignature integration&202012030925&KtQGx6qthd9qD2vHzin+Z1mL//Tsb20bA65jGjOnTZ2Yh4yw+wW/RLg8bfubLBETwjifV7J39p58SXHPe+HxDw=="
      "ApimConfiguration__AzureApiUri"    = "https://sapience-lab-us-qa.management.azure-api.net"
      "ApimConfiguration__HomeUrl"        = "https://sapience-lab-us-qa.developer.azure-api.net"
      "ApimConfiguration__ResourceGroup"  = var.resource_group_name
      "ApimConfiguration__ServiceName"    = "sapience-lab-us-qa"
      "ApimConfiguration__SubscriptionId" = var.subscription_id
      "ApimConfiguration__ClientId"       = "eFDVhAEhXevxOdKksxseDpsWhJJIWR1C"
      "ApimConfiguration__Authority"      = "https://qa-sapienceanalytics.auth0.com"
      
  }
}
