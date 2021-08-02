 terraform {
   backend "azurerm" {
     key = "database.tfstate"
   }
 }

 provider "azurerm" {
   version         = "2.27.0"
   subscription_id = var.subscription_id
   features {}
 }

 data "terraform_remote_state" "aks_egress" {
   backend = "azurerm"

   config = {
     access_key           = var.realm_backend_access_key
     storage_account_name = var.realm_backend_storage_account_name
     container_name       = var.realm_backend_container_name
     key                  = "black/aks-egress.tfstate"
   }
 }

locals {
  sql_server_version                    = "12.0"
  sql_server_administrator_login        = var.sql_server_administrator_login
  sql_server_administrator_password     = var.sql_server_administrator_password
  # sedw_requested_service_objective_name = var.sedw_requested_service_objective_name
  cosmos_failover_location              = "eastus2"

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

resource "azurerm_mysql_database" "marketplace" {
  name                = "marketplace"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_server.sapience.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}


resource "azurerm_sql_database" "automation" {
  name                             = "automation-reporting-db"
  resource_group_name              = azurerm_sql_server.sapience.resource_group_name
  location                         = azurerm_sql_server.sapience.location
  server_name                      = azurerm_sql_server.sapience.name
  edition                          = var.sql_database_automation_edition
  requested_service_objective_name = var.sql_database_automation_requested_service_objective_name

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

resource "azurerm_sql_database" "Staging" {
  name                             = "Staging"
  resource_group_name              = azurerm_sql_server.sapience.resource_group_name
  location                         = azurerm_sql_server.sapience.location
  server_name                      = azurerm_sql_server.sapience.name
  edition                          = var.sql_database_staging_edition
  requested_service_objective_name = var.sql_database_staging_requested_service_objective_name

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

resource "azurerm_cosmosdb_account" "lab_us_qa" {
  name                = "sapience-app-dashboard-${var.realm}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Strong"
  }

  geo_location {
    location          = local.cosmos_failover_location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_account" "lab_us_qa_dashboard_mongodb" {
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

resource "azurerm_cosmosdb_account" "sapience-integration-mongodb-lab-us-qa" {
  name                = "sapience-integration-mongodb-${var.realm}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  offer_type          = "Standard"
  kind                = "MongoDB"
  is_virtual_network_filter_enabled = true
  ip_range_filter                   = "47.190.73.52,219.91.160.58,210.16.93.186,20.81.225.32,40.71.98.165,104.42.195.92,40.76.54.131,52.176.6.30,52.169.50.45,52.187.184.26"

  capabilities  {
    name = "EnableAggregationPipeline"
  }

  virtual_network_rule {
    id = "/subscriptions/b78a61e7-f2ed-4cb0-8f48-6548408935e9/resourceGroups/lab-red-us/providers/Microsoft.Network/virtualNetworks/lab-red-us/subnets/aks-pool01"
  }
  capabilities {
    name = "EnableMongo"
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

resource "azurerm_cosmosdb_account" "lab_us_qa_alerts_mongodb" {
  name                = "sapience-app-alerts-mongodb-${var.realm}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  offer_type          = "Standard"
  kind                = "MongoDB"

  consistency_policy {
    consistency_level = "Strong"
  }

  capabilities {
         name = "EnableAggregationPipeline"
  }
  
  capabilities {
    name = "EnableMongo"
  }

  capabilities {
      name = "MongoDBv3.4"
  }

  geo_location {
    location          = local.cosmos_failover_location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_account" "lab_us_bulk_upload_mongodb" {
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

resource "azurerm_cosmosdb_account" "canopy_settings_mongodb" {
  name                = "canopy-settings-mongodb-${var.realm}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  offer_type          = "Standard"
  kind                = "MongoDB"

  consistency_policy {
    consistency_level = "Strong"
  }

  capabilities {
        name = "AllowSelfServeUpgradeToMongo36"
  }
  
  capabilities {
        name = "DisableRateLimitingResponses"
  }

  geo_location {
    location          = local.cosmos_failover_location
    failover_priority = 0
  }
}

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
  ssl_enforcement_enabled     = true
  sku_name   = var.mysql_server_sku_name

  storage_profile {
    storage_mb            = var.mysql_server_storage_profile_storage_mb
    backup_retention_days = 14
    geo_redundant_backup  = "Disabled"
    auto_grow             = "Disabled"
  }

  administrator_login          = var.mysql_server_administrator_login
  administrator_login_password = var.mysql_server_administrator_password
  version                      = var.mysql_server_version
  #ssl_enforcement              = "Enabled"
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

resource "azurerm_mysql_database" "kpi1" {
  name                = "kpi1"
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

resource "azurerm_mysql_database" "location" {
  name                = "location"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_server.sapience.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

resource "azurerm_mysql_database" "notification" {
  name                = "notification"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_server.sapience.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

resource "azurerm_mysql_database" "setting" {
  name                = "setting"
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