resource "kubernetes_config_map" "cyclr" {
  metadata {
    name      = "cyclr"
    namespace = local.namespace
  }

  data = {
      "CyclrSettings__BaseHost"         =  "https://api.integrations.nonprod.sapienceanalytics.com"
      "CyclrSettings__GrantType"        =  "client_credentials"
      "CyclrSettings__OAuthRedirectUrl" =  "https://demo.integrations.nonprod.sapienceanalytics.com/connectorauth/updateaccountconnectoroauth"
      "SqlServerSettings__Server"       =  "sapience-lab-us-demo.database.windows.net"
      "SqlServerSettings__User"         =  "staging_etl_user"      
        }
}