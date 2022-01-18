resource "kubernetes_config_map" "apim" {
  metadata {
    name      = "apim"
    namespace = local.namespace
  }

  data = {
    #APIM Open-API
      "ApimConfiguration__AccessToken"    = "SharedAccessSignature integration&202012031243&GSflUoH1jzVSaMvOjxCSJ3vsL3YWqtsdddfsY4e3UxsBYJKJEb8E36TzB/uVxlo9sh7grNTDWRKs4friMvIc4qNmxQ=="
      "ApimConfiguration__AzureApiUri"    = "https://sapience-prep-us-prep.management.azure-api.net"
      "ApimConfiguration__HomeUrl"        = "https://sapience-prep-us-prep.developer.azure-api.net"
      "ApimConfiguration__ResourceGroup"  = var.resource_group_name
      "ApimConfiguration__ServiceName"    = "sapience-prep-us-prep"
      "ApimConfiguration__SubscriptionId" = var.subscription_id
      "ApimConfiguration__ClientId"       = "DtUve4ZspdddmZAbbrYYKdBGm3dvjqz16AO"
      "ApimConfiguration__Authority"      = "https://sapience-prep-us-prep.auth0.com"
      
  }
}
