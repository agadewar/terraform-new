resource "kubernetes_secret" "cyclr" {
  metadata {
    name      = "cyclr"
    namespace = local.namespace
  }
data = {
    CyclrSettings__ClientId     =  var.cyclr_client_id
    CyclrSettings__ClientSecret =  var.cyclr_client_secret
}
}