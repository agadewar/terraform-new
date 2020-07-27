terraform {
  backend "azurerm" {
    key = "service-bus.tfstate"
  }
}

provider "azurerm" {
  version         = "1.31.0"
  subscription_id = var.subscription_id
}

# data "terraform_remote_state" "resource_group" {
#   backend = "azurerm"
#   config {
#     access_key           = "${var.backend_access_key}"
#     storage_account_name = "${var.backend_storage_account_name}"
# 	  container_name       = "environment-${var.environment}"
#     key                  = "resource-group.tfstate"
#   }
# }

locals {
  common_tags = merge(
    var.realm_common_tags,
    var.environment_common_tags,
    {
      "Component" = "Service Bus"
    },
  )
}

resource "azurerm_servicebus_namespace" "namespace" {
  name                = "sapience-${var.realm}-${var.environment}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  tags = merge(local.common_tags, {})
}

# resource "azurerm_servicebus_queue" "canopy_eventpipeline" {
#   name                = "sapience-canopy-eventpipeline"
#   resource_group_name = var.resource_group_name
#   namespace_name      = azurerm_servicebus_namespace.namespace.name

#   enable_partitioning = true
# }

resource "azurerm_servicebus_queue" "device_registration" {
  name                = "device-registration"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name

  enable_partitioning = true
}

# resource "azurerm_servicebus_queue" "event_archive" {
#   name                = "event-archive"
#   resource_group_name = var.resource_group_name
#   namespace_name      = azurerm_servicebus_namespace.namespace.name

#   enable_partitioning = true
# }


resource "azurerm_servicebus_queue" "canopy-device-agent-info" {
  name                = "canopy-device-agent-info"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  max_size_in_megabytes = "1024"

  enable_partitioning = false
}

resource "azurerm_servicebus_queue" "canopy-device-device-component" {
  name                = "canopy-device-device-component"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  max_size_in_megabytes = 1024

  enable_partitioning = false
}

resource "azurerm_servicebus_queue" "canopy-device-device-event" {
  name                = "canopy-device-device-event"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  max_size_in_megabytes = 1024

  enable_partitioning = false
}

resource "azurerm_servicebus_queue" "canopy-device-file-version" {
  name                = "canopy-device-file-version"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  max_size_in_megabytes = 1024

  enable_partitioning = false

}

resource "azurerm_servicebus_queue" "canopy-device-generic-data-info" {
  name                = "canopy-device-generic-data-info"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  max_size_in_megabytes = 1024

  enable_partitioning = false

}

resource "azurerm_servicebus_queue" "canopy-device-heartbeat" {
  name                = "canopy-device-heartbeat"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  max_size_in_megabytes = 1024

  enable_partitioning = false

}

resource "azurerm_servicebus_queue" "canopy-device-leaf-versions" {
  name                = "canopy-device-leaf-versions"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  max_size_in_megabytes = 1024

  enable_partitioning = false

}

resource "azurerm_servicebus_queue" "canopy-device-software-update" {
  name                = "canopy-device-software-update"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  max_size_in_megabytes = 1024

  enable_partitioning = false

}

resource "azurerm_servicebus_queue" "canopy-device-system-info" {
  name                = "canopy-device-system-info"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  max_size_in_megabytes = 1024

  enable_partitioning = false

}

  resource "azurerm_servicebus_queue" "canopy-device-system-utilization" {
  name                = "canopy-device-system-utilization"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  max_size_in_megabytes = 1024

  enable_partitioning = false

  }

  resource "azurerm_servicebus_queue" "canopy-kpi" {
  name                = "canopy-kpi"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  max_size_in_megabytes = 1024

  enable_partitioning = false

  }

 resource "azurerm_servicebus_queue" "canopy-location-action-scheduler" {
  name                = "canopy-location-action-scheduler"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  max_size_in_megabytes = 1024

  enable_partitioning = false

 }

 resource "azurerm_servicebus_queue" "canopy-notification-email" {
  name                = "canopy-notification-email"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  max_size_in_megabytes = 1024

  enable_partitioning = false

 }

 resource "azurerm_servicebus_queue" "canopy-notification-push-notification" {
  name                = "canopy-notification-push-notification"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  max_size_in_megabytes = 1024

  enable_partitioning = false

 }

resource "azurerm_servicebus_queue" "canopy-notification-sms" {
  name                = "canopy-notification-sms"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  max_size_in_megabytes = 1024

  enable_partitioning = false

 }

resource "azurerm_servicebus_queue" "canopy-notification-twilio" {
  name                = "canopy-notification-twilio"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  max_size_in_megabytes = 1024

  enable_partitioning = false

 }
 
 resource "azurerm_servicebus_queue" "canopy-publish" {
  name                = "canopy-publish"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  max_size_in_megabytes = 1024

  enable_partitioning = false

 }