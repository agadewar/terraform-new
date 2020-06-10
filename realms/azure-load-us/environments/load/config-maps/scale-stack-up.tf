resource "kubernetes_config_map" "scale-stack-up" {
  metadata {
    name      = "scale-stack-up"
    namespace = local.namespace
  }

  data = {
      "ambassador"                       = "8"
      "canopy-auth0-service"             = "1"
      "canopy-auth0-service"             = "6"
      "canopy-device-service"            = "2"
      "canopy-hierarchy-service"         = "2"
      "canopy-location-service"          = "1"
      "canopy-marketplace-service"       = "2"
      "canopy-notification-service"      = "2" 
      "canopy-setting-service"           = "2"
      "canopy-settings-service"          = "4"
      "canopy-user-service"              = "2"
      "canopy-v2"                        = "2"
      "etl-staging-database"             = "1"
      "eventpipeline-leaf-broker"        = "6"
      "eventpipeline-registry"           = "2"
      "eventpipeline-service"            = "18"
      "kpi-service"                      = "8"
      "sapience-admin-ui"                = "1"
      "sapience-app-alerts"              = "2"
      "sapience-app-api"                 = "2"
      "sapience-help"                    = "1"
      "sapience-ui"                      = "2"
      "vault-load-agent-injector"        = "1"
  }
}
