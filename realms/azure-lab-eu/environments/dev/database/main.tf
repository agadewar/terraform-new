terraform {
  backend "azurerm" {
    key = "database.tfstate"
  }
}

provider "azurerm" {
  version         = "1.31.0"
  subscription_id = var.subscription_id
}

data "terraform_remote_state" "aks_egress" {
  backend = "azurerm"

  config = {
    access_key           = var.realm_backend_access_key
    storage_account_name = var.realm_backend_storage_account_name
    container_name       = var.realm_backend_container_name
    key                  = "../azure-red-eu/red/aks-egress.tfstate"
  }
}

locals {
  sql_server_version                      = "12.0"
  sql_server_administrator_login          = var.sql_server_administrator_login
  sql_server_administrator_password       = var.sql_server_administrator_password
  # sedw_requested_service_objective_name = var.sedw_requested_service_objective_name
  cosmos_failover_location                = var.failover_location

  common_tags = merge(
    var.realm_common_tags,
    var.environment_common_tags,
    {
      "Component" = "Database"
    },
  )
}

resource "azurerm_sql_server" "sapience" {
  name                         = "sapience-${var.realm}-${var.environment}"
  resource_group_name          = var.resource_group_name
  location                     = var.resource_group_location
  version                      = local.sql_server_version
  administrator_login          = local.sql_server_administrator_login
  administrator_login_password = local.sql_server_administrator_password

  tags = merge(local.common_tags, {})
}

resource "azurerm_sql_database" "Admin" {
  name                             = "Admin"
  resource_group_name              = azurerm_sql_server.sapience.resource_group_name
  location                         = azurerm_sql_server.sapience.location
  server_name                      = azurerm_sql_server.sapience.name
  edition                          = var.sql_database_admin_edition
  requested_service_objective_name = var.sql_database_admin_requested_service_objective_name

  tags = merge(local.common_tags, {})
}

resource "azurerm_sql_database" "EDW" {
  name                             = "EDW"
  resource_group_name              = azurerm_sql_server.sapience.resource_group_name
  location                         = azurerm_sql_server.sapience.location
  server_name                      = azurerm_sql_server.sapience.name
  edition                          = var.sql_database_edw_edition
  requested_service_objective_name = var.sql_database_edw_requested_service_objective_name

  tags = merge(local.common_tags, {})
}

resource "azurerm_sql_firewall_rule" "aks_egress" {
  name                = "aks-egress"
  resource_group_name = azurerm_sql_server.sapience.resource_group_name
  server_name         = azurerm_sql_server.sapience.name
  start_ip_address    = data.terraform_remote_state.aks_egress.outputs.aks_egress_ip_address
  end_ip_address      = data.terraform_remote_state.aks_egress.outputs.aks_egress_ip_address
}

resource "azurerm_sql_firewall_rule" "ip_sapience_dallas_office" {
  name                = "ip-sapience-dallas-office"
  resource_group_name = azurerm_sql_server.sapience.resource_group_name
  server_name         = azurerm_sql_server.sapience.name
  start_ip_address    = var.ip_sapience_dallas_office
  end_ip_address      = var.ip_sapience_dallas_office
}

resource "azurerm_sql_firewall_rule" "ip_sapience_pune_office" {
  name                = "ip-sapience-pune-office"
  resource_group_name = azurerm_sql_server.sapience.resource_group_name
  server_name         = azurerm_sql_server.sapience.name
  start_ip_address    = var.ip_sapience_pune_office
  end_ip_address      = var.ip_sapience_pune_office
}

resource "azurerm_sql_firewall_rule" "ip_sapience_pune2_office" {
  name                = "ip-sapience-pune2-office"
  resource_group_name = azurerm_sql_server.sapience.resource_group_name
  server_name         = azurerm_sql_server.sapience.name
  start_ip_address    = var.ip_sapience_pune2_office
  end_ip_address      = var.ip_sapience_pune2_office
}

resource "azurerm_cosmosdb_account" "sapience_canopy_hierarchy" {
  name                = "sapience-canopy-hierarchy-${var.realm}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  capabilities {
    name = "EnableGremlin"
  }

  consistency_policy {
    consistency_level = "Strong"
  }

  geo_location {
    location          = local.cosmos_failover_location
    failover_priority = 0
  }
}

#resource "azurerm_cosmosdb_account" "lab_eu_dev_dashboard_mongodb" {
#  name                = "sapience-app-dashboard-mongodb-${var.realm}-${var.environment}"
#  resource_group_name = var.resource_group_name
#  location            = var.resource_group_location
#  offer_type          = "Standard"
#  kind                = "MongoDB"

#  consistency_policy {
#    consistency_level = "Strong"
#  }

#  geo_location {
#    location          = local.cosmos_failover_location
#    failover_priority = 0
#  }
#}

#resource "azurerm_cosmosdb_account" "lab_eu_dev_alerts" {
#  name                = "sapience-app-alerts-${var.realm}-${var.environment}"
#  resource_group_name = var.resource_group_name
#  location            = var.resource_group_location
#  offer_type          = "Standard"
#  kind                = "GlobalDocumentDB"

#  consistency_policy {
#    consistency_level = "Strong"
#  }

#  geo_location {
#    location          = local.cosmos_failover_location
#    failover_priority = 0
#  }
#}

resource "azurerm_cosmosdb_account" "lab_eu_dev_alerts_mongodb" {
  name                = "sapience-app-alerts-mongodb-${var.realm}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  offer_type          = "Standard"
  kind                = "MongoDB"

  capabilities  {
    name = "EnableAggregationPipeline"
  }
  capabilities  {
    name = "MongoDBv3.4"
  }
  consistency_policy {
    consistency_level = "Strong"
  }

  geo_location {
    location          = local.cosmos_failover_location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_account" "lab_eu_dev_app_dashboard_mongodb" {
  name                = "sapience-app-dashboard-mongodb-${var.realm}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  offer_type          = "Standard"
  kind                = "MongoDB"

  capabilities  {
    name = "EnableAggregationPipeline"
  }
  capabilities  {
    name = "MongoDBv3.4"
  }
  consistency_policy {
    consistency_level = "Strong"
  }

  geo_location {
    location          = local.cosmos_failover_location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_account" "lab_eu_dev_bulk_upload_mongodb" {
  name                = "sapience-bulk-upload-mongodb-${var.realm}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  offer_type          = "Standard"
  kind                = "MongoDB"

  capabilities  {
    name = "EnableAggregationPipeline"
  }
  capabilities  {
    name = "MongoDBv3.4"
  }
  consistency_policy {
    consistency_level = "Strong"
  }

  geo_location {
    location          = local.cosmos_failover_location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_account" "lab_eu_dev_canopy_settings_mongodb" {
  name                = "canopy-settings-mongodb-${var.realm}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  offer_type          = "Standard"
  kind                = "MongoDB"

  consistency_policy {
    consistency_level = "Strong"
  }

  geo_location {
    location          = local.cosmos_failover_location
    failover_priority = 0
  }
}

# resource "azurerm_cosmosdb_account" "sapience_graph" {
#   name                = "sapience-graph-${var.environment}"
#   resource_group_name = var.resource_group_name
#   location            = var.resource_group_location
#   offer_type          = "Standard"
#   kind                = "GlobalDocumentDB"

#   capabilities {
#     name = "EnableGremlin"
#   }

#   consistency_policy {
#     consistency_level = "Strong"
#   }

#   geo_location {
#     location          = local.cosmos_failover_location
#     failover_priority = 0
#   }
# }

# resource "azurerm_cosmosdb_account" "event_archive" {
#   name                = "sapience-event-archive-${var.environment}"
#   resource_group_name = var.resource_group_name
#   location            = var.resource_group_location
#   offer_type          = "Standard"

#   capabilities {
#     name = "EnableCassandra"
#   }

#   consistency_policy {
#     consistency_level = "Eventual"
#   }

#   geo_location {
#     location          = local.cosmos_failover_location
#     failover_priority = 0
#   }
# }

resource "azurerm_mysql_firewall_rule" "aks_egress" {
  name                = "aks-egress"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_server.sapience.name
  start_ip_address    = data.terraform_remote_state.aks_egress.outputs.aks_egress_ip_address
  end_ip_address      = data.terraform_remote_state.aks_egress.outputs.aks_egress_ip_address
}

resource "azurerm_mysql_firewall_rule" "sapience_dallas_office" {
  name                = "Sapience-Dallas-Office"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_server.sapience.name
  start_ip_address    = var.ip_sapience_dallas_office
  end_ip_address      = var.ip_sapience_dallas_office
}

resource "azurerm_mysql_firewall_rule" "sapience-pune-office" {
  name                = "Sapience-Pune-Office"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_server.sapience.name
  start_ip_address    = var.ip_sapience_pune_office
  end_ip_address      = var.ip_sapience_pune_office
}

resource "azurerm_mysql_firewall_rule" "sapience-pune2-office" {
  name                = "Sapience-Pune2-Office"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_server.sapience.name
  start_ip_address    = var.ip_sapience_pune2_office
  end_ip_address      = var.ip_sapience_pune2_office
}

resource "azurerm_mysql_server" "sapience" {
  name                = "sapience-mysql-${var.realm}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location

  sku {
    name     = var.mysql_server_sku_name
    capacity = var.mysql_server_sku_capacity
    tier     = var.mysql_server_sku_tier
    family   = var.mysql_server_sku_family
  }

  storage_profile {
    storage_mb            = var.mysql_server_storage_profile_storage_mb
    backup_retention_days = 14
    geo_redundant_backup  = "Disabled"
  }

  administrator_login          = var.mysql_server_administrator_login
  administrator_login_password = var.mysql_server_administrator_password
  version                      = var.mysql_server_version
  ssl_enforcement              = "Enabled"
}

resource "azurerm_mysql_configuration" "sapience_log_bin_trust_function_creators" {
  name                = "log_bin_trust_function_creators"
  resource_group_name = var.resource_group_name
  server_name         = "${azurerm_mysql_server.sapience.name}"
  value               = "ON"
}

resource "azurerm_mysql_database" "auth0" {
  name                = "auth0"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_server.sapience.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

resource "azurerm_mysql_database" "device" {
  name                = "device"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_server.sapience.name
  charset             = "latin1"
  collation           = "latin1_swedish_ci"
}

resource "azurerm_mysql_database" "eventpipeline" {
  name                = "eventpipeline"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_server.sapience.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

resource "azurerm_mysql_database" "leafbroker" {
  name                = "leafbroker"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_server.sapience.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

resource "azurerm_mysql_database" "marketplace" {
  name                = "marketplace"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_server.sapience.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

resource "azurerm_mysql_database" "user" {
  name                = "user"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_server.sapience.name
  charset             = "latin1"
  collation           = "latin1_swedish_ci"
}

resource "azurerm_cosmosdb_account" "sapience-integration-mongodb-lab-eu-dev" {
  name                = "sapience-integration-mongodb-${var.realm}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  offer_type          = "Standard"
  kind                = "MongoDB"

  capabilities  {
    name = "EnableAggregationPipeline"
  }
  capabilities  {
    name = "MongoDBv3.4"
  }
  consistency_policy {
    consistency_level = "Strong"
  }

  geo_location {
    location          = local.cosmos_failover_location
    failover_priority = 0
  }
}

#resource "azurerm_cosmosdb_account" "integrations_mongodb" {
#  name                = "sapience-integrations-mongodb-${var.realm}-${var.environment}"
#  resource_group_name = var.resource_group_name
#  location            = var.resource_group_location
#  offer_type          = "Standard"
#  kind                = "MongoDB"

#  consistency_policy {
#    consistency_level = "Strong"
#  }

#  geo_location {
#    location          = local.cosmos_failover_location
#    failover_priority = 0
#  }
#}

resource "azurerm_redis_cache" "redis_cache" {
  name                = "sapience-redis-cache-${var.realm}-${var.environment}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  capacity            = 2
  family              = "C"
  sku_name            = "Standard"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"

  redis_configuration {
  }
}

# resource "azurerm_redis_firewall_rule" "firewall_redis_cache" {
#   name                = "someIPrange"
#   redis_cache_name    = azurerm_redis_cache.redis_cache.name
#   resource_group_name = var.resource_group_name
#   start_ip            = data.terraform_remote_state.aks_egress.outputs.aks_egress_ip_address
#   end_ip              = data.terraform_remote_state.aks_egress.outputs.aks_egress_ip_address
# }
