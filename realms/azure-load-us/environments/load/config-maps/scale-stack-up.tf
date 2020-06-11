resource "kubernetes_config_map" "scale-stack-up" {
  metadata {
    name      = "scale-stack-up"
    namespace = local.namespace
  }

  data = {
      "ambassador"                       = "8"
      "canopy_auth0_service"             = "1"
      "canopy_auth0_service"             = "6"
      "canopy_device_service"            = "2"
      "canopy_hierarchy_service"         = "2"
      "canopy_location_service"          = "1"
      "canopy_marketplace_service"       = "2"
      "canopy_notification_service"      = "2" 
      "canopy_setting_service"           = "2"
      "canopy_settings_service"          = "4"
      "canopy_user_service"              = "2"
      "canopy_v2"                        = "2"
      "etl_staging_database"             = "1"
      "eventpipeline_leaf_broker"        = "6"
      "eventpipeline_registry"           = "2"
      "eventpipeline_service"            = "18"
      "kpi_service"                      = "8"
      "sapience_admin_ui"                = "1"
      "sapience_app_alerts"              = "2"
      "sapience_app_api"                 = "2"
      "sapience_help"                    = "1"
      "sapience_ui"                      = "2"
      "vault_load_agent_injector"        = "1"
  }
}
