resource "kubernetes_config_map" "scale-stack-up" {
  metadata {
    name      = "scale-stack-up"
    namespace = local.namespace
  }

  data = {
      "ambassador"                       = "8"
      "canopy_auth0_service"             = "2"
      "canopy_device_service"            = "12"
      "canopy_hierarchy_service"         = "12"
      "canopy_location_service"          = "2"
      "canopy_marketplace_service"       = "2"
      "canopy_notification_service"      = "2" 
      "canopy_setting_service"           = "2"
      "canopy_settings_service"          = "2"
      "canopy_user_service"              = "12"
      "canopy_v2"                        = "2"
      "etl_staging_database"             = "8"
      "eventpipeline_leaf_broker"        = "12"
      "eventpipeline_registry"           = "2"
      "eventpipeline_service"            = "16"
      "kpi_service"                      = "8"
      "sapience_admin_ui"                = "1"
      "sapience_app_alerts"              = "1"
      "sapience_app_api"                 = "1"
      "sapience_help"                    = "1"
      "sapience_ui"                      = "1"
      "vault_load_agent_injector"        = "1"
  }
}
