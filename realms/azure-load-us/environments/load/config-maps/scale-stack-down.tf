resource "kubernetes_config_map" "scale-stack-down" {
  metadata {
    name      = "scale-stack-down"
    namespace = local.namespace
  }

  data = {
      "ambassador"                       = "0"
      "canopy-auth0-service"             = "0"
      "canopy-auth0-service"             = "0"
      "canopy-device-service"            = "0"
      "canopy-hierarchy-service"         = "0"
      "canopy-location-service"          = "0"
      "canopy-marketplace-service"       = "0"
      "canopy-notification-service"      = "0" 
      "canopy-setting-service"           = "0"
      "canopy-settings-service"          = "0"
      "canopy-user-service"              = "0"
      "canopy-v2"                        = "0"
      "etl-staging-database"             = "0"
      "eventpipeline-leaf-broker"        = "0"
      "eventpipeline-registry"           = "0"
      "eventpipeline-service"            = "0"
      "kpi-service"                      = "0"
      "sapience-admin-ui"                = "0"
      "sapience-app-alerts"              = "0"
      "sapience-app-api"                 = "0"
      "sapience-help"                    = "0"
      "sapience-ui"                      = "0"
      "vault-load-agent-injector"        = "0"
  }
}
