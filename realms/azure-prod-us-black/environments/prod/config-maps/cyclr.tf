resource "kubernetes_config_map" "cyclr" {
  metadata {
    name      = "cyclr"
    namespace = local.namespace
  }

  data = {
      "CyclrSettings__BaseHost"         =  "https://api.integrations.sapienceanalytics.com"
      "CyclrSettings__GrantType"        =  "client_credentials"
      "CyclrSettings__OAuthRedirectUrl" =  "https://integrations.sapienceanalytics.com/connectorauth/updateaccountconnectoroauth"
      "SqlServerSettings__Server"       =  "sapience-prod-us-prod.database.windows.net"
      "SqlServerSettings__User"         =  "staging_etl_user"
        }
}