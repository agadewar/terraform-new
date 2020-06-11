resource "kubernetes_config_map" "scale-stack-down" {
  metadata {
    name      = "scale-stack-down"
    namespace = local.namespace
  }

  data = {
      "ambassador"                       = "0"
      "canopy_auth0_service"             = "0"
      "canopy_auth0_service"             = "0"
      "canopy_device_service"            = "0"
      "canopy_hierarchy_service"         = "0"
      "canopy_location_service"          = "0"
      "canopy_marketplace_service"       = "0"
      "canopy_notification_service"      = "0" 
      "canopy_setting_service"           = "0"
      "canopy_settings_service"          = "0"
      "canopy_user_service"              = "0"
      "canopy_v2"                        = "0"
      "etl_staging_database"             = "0"
      "eventpipeline_leaf_broker"        = "0"
      "eventpipeline_registry"           = "0"
      "eventpipeline_service"            = "0"
      "kpi_service"                      = "0"
      "sapience_admin_ui"                = "0"
      "sapience_app_alerts"              = "0"
      "sapience_app_api"                 = "0"
      "sapience_help"                    = "0"
      "sapience_ui"                      = "0"
      "vault_load_agent_injector"        = "0"
  }
}
