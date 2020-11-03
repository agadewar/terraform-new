resource "kubernetes_secret" "apim" {
  metadata {
    name = "apim"
    namespace = local.namespace
  }

  data = {
    #APIM Open-API
      "ApimConfiguration__DelegationKey"  = "var.ApimConfiguration__DelegationKey"
      "ApimConfiguration__ClientSecret"   = "var.ApimConfiguration__ClientSecret"
  }
}
