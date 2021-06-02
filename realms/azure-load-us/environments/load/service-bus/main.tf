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
  sku                 = "Premium"
  capacity            = "4"

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

  enable_partitioning = false
}

resource "azurerm_servicebus_queue" "canopy_deadend" {
  name                = "canopy-deadend"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name

  enable_partitioning = false
}

# resource "azurerm_servicebus_queue" "event_archive" {
#   name                = "event-archive"
#   resource_group_name = var.resource_group_name
#   namespace_name      = azurerm_servicebus_namespace.namespace.name

#   enable_partitioning = true
# }

resource "azurerm_servicebus_topic" "sapience-admin-users-created" {
  name                            = "sapience-admin-users-created"
  resource_group_name             = var.resource_group_name
  namespace_name                  = azurerm_servicebus_namespace.namespace.name
  
  enable_partitioning = false

}

resource "azurerm_servicebus_topic_authorization_rule" "sapience-admin-users-created-publish" {
  name                = "Publish"
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-users-created.name
  resource_group_name = var.resource_group_name
  listen              = false
  send                = true
  manage              = false
}

resource "azurerm_servicebus_topic_authorization_rule" "sapience-admin-users-created-subscribe" {
  name                = "Subscribe"
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-users-created.name
  resource_group_name = var.resource_group_name
  listen              = true
  send                = false
  manage              = false
}

resource "azurerm_servicebus_topic_authorization_rule" "sapience-admin-users-created-full" {
  name                = "Full"
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-users-created.name
  resource_group_name = var.resource_group_name
  listen              = true
  send                = true
  manage              = true
}

resource "azurerm_servicebus_subscription" "subscriptions-auth0" {
  name                = "sapience-admin-users-created-subscriptions_auth0"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-users-created.name
  
  max_delivery_count  = 10
  #auto_delete_on_idle = 10
  requires_session = false

}

resource "azurerm_servicebus_subscription" "subscriptions-sisense" {
  name                = "sapience-admin-users-created-subscriptions_sisense"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-users-created.name
  
  max_delivery_count  = 10
  #auto_delete_on_idle = 10
  requires_session = false

}

resource "azurerm_servicebus_subscription" "subscriptions-canopy" {
  name                = "sapience-admin-users-created-subscriptions_canopy"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-users-created.name
  
  max_delivery_count  = 10
  #auto_delete_on_idle = 10
  requires_session = false

}

resource "azurerm_servicebus_topic" "sapience-admin-users-deleted" {
  name                = "sapience-admin-users-deleted"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name

  enable_partitioning = false

}

resource "azurerm_servicebus_topic_authorization_rule" "sapience-admin-users-deleted-publish" {
  name                = "Publish"
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-users-deleted.name
  resource_group_name = var.resource_group_name
  listen              = false
  send                = true
  manage              = false
}

resource "azurerm_servicebus_topic_authorization_rule" "sapience-admin-users-deleted-subscribe" {
  name                = "Subscribe"
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-users-deleted.name
  resource_group_name = var.resource_group_name
  listen              = true
  send                = false
  manage              = false
}

resource "azurerm_servicebus_topic_authorization_rule" "sapience-admin-users-deleted-full" {
  name                = "Full"
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-users-deleted.name
  resource_group_name = var.resource_group_name
  listen              = true
  send                = true
  manage              = true
}

resource "azurerm_servicebus_subscription" "sapience-admin-users-deleted-subscriptions_auth0" {
  name                = "sapience-admin-users-deleted-subscriptions_auth0"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-users-deleted.name
  
  max_delivery_count  = 10
  #auto_delete_on_idle = 10
  requires_session = false

}

resource "azurerm_servicebus_subscription" "sapience-admin-users-deleted-subscriptions_sisense" {
  name                = "sapience-admin-users-deleted-subscriptions_sisense"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-users-deleted.name
  
  max_delivery_count  = 10
  #auto_delete_on_idle = 10
  requires_session = false

}

resource "azurerm_servicebus_subscription" "sapience-admin-users-deleted-subscriptions_canopy" {
  name                = "sapience-admin-users-deleted-subscriptions_canopy"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-users-deleted.name
  
  max_delivery_count  = 10
  #auto_delete_on_idle = 10
  requires_session = false

}

resource "azurerm_servicebus_topic" "sapience-admin-users-updated" {
  name                = "sapience-admin-users-updated"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name

  enable_partitioning = false

}

resource "azurerm_servicebus_topic_authorization_rule" "sapience-admin-users-updated-publish" {
  name                = "Publish"
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-users-updated.name
  resource_group_name = var.resource_group_name
  listen              = false
  send                = true
  manage              = false
}

resource "azurerm_servicebus_topic_authorization_rule" "sapience-admin-users-updated-subscribe" {
  name                = "Subscribe"
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-users-updated.name
  resource_group_name = var.resource_group_name
  listen              = true
  send                = false
  manage              = false
}

resource "azurerm_servicebus_topic_authorization_rule" "sapience-admin-users-updated-full" {
  name                = "Full"
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-users-updated.name
  resource_group_name = var.resource_group_name
  listen              = true
  send                = true
  manage              = true
}

resource "azurerm_servicebus_subscription" "sapience-admin-users-updated-subscriptions_auth0" {
  name                = "sapience-admin-users-updated-subscriptions_auth0"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-users-updated.name
  
  max_delivery_count  = 10
  #auto_delete_on_idle = 10
  requires_session = false

}

resource "azurerm_servicebus_subscription" "sapience-admin-users-updated-subscriptions_sisense" {
  name                = "sapience-admin-users-updated-subscriptions_sisense"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-users-updated.name
  
  max_delivery_count  = 10
  #auto_delete_on_idle = 10
  requires_session = false

}

resource "azurerm_servicebus_subscription" "sapience-admin-users-updated-subscriptions_canopy" {
  name                = "sapience-admin-users-updated-subscriptions_canopy"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-users-updated.name
  
  max_delivery_count  = 10
  #auto_delete_on_idle = 10
  requires_session = false

}

resource "azurerm_servicebus_topic" "sapience-admin-teams-created" {
  name                = "sapience-admin-teams-created"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name

  enable_partitioning = false

}

resource "azurerm_servicebus_topic_authorization_rule" "sapience-admin-teams-created-publish" {
  name                = "Publish"
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-teams-created.name
  resource_group_name = var.resource_group_name
  listen              = false
  send                = true
  manage              = false
}

resource "azurerm_servicebus_topic_authorization_rule" "sapience-admin-teams-created-subscribe" {
  name                = "Subscribe"
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-teams-created.name
  resource_group_name = var.resource_group_name
  listen              = true
  send                = false
  manage              = false
}

resource "azurerm_servicebus_topic_authorization_rule" "sapience-admin-teams-created-full" {
  name                = "Full"
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-teams-created.name
  resource_group_name = var.resource_group_name
  listen              = true
  send                = true
  manage              = true
}

resource "azurerm_servicebus_subscription" "sapience-admin-teams-created-subscriptions_auth0" {
  name                = "sapience-admin-teams-created-subscriptions_auth0"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-teams-created.name
  
  max_delivery_count  = 10
  #auto_delete_on_idle = 10
  requires_session = false

}

resource "azurerm_servicebus_subscription" "sapience-admin-teams-created-subscriptions_sisense" {
  name                = "sapience-admin-teams-created-subscriptions_sisense"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-teams-created.name
  
  max_delivery_count  = 10
  #auto_delete_on_idle = 10
  requires_session = false

}

resource "azurerm_servicebus_topic" "sapience-admin-teams-updated" {
  name                = "sapience-admin-teams-updated"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name

  enable_partitioning = false

}

resource "azurerm_servicebus_topic_authorization_rule" "sapience-admin-teams-updated-publish" {
  name                = "Publish"
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-teams-updated.name
  resource_group_name = var.resource_group_name
  listen              = false
  send                = true
  manage              = false
}

resource "azurerm_servicebus_topic_authorization_rule" "sapience-admin-teams-updated-subscribe" {
  name                = "Subscribe"
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-teams-updated.name
  resource_group_name = var.resource_group_name
  listen              = true
  send                = false
  manage              = false
}

resource "azurerm_servicebus_topic_authorization_rule" "sapience-admin-teams-updated-full" {
  name                = "Full"
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-teams-updated.name
  resource_group_name = var.resource_group_name
  listen              = true
  send                = true
  manage              = true
}

resource "azurerm_servicebus_subscription" "sapience-admin-teams-updated-subscriptions_auth0" {
  name                = "sapience-admin-teams-updated-subscriptions_auth0"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-teams-updated.name
  
  max_delivery_count  = 10
  #auto_delete_on_idle = 10
  requires_session = false

}

resource "azurerm_servicebus_subscription" "sapience-admin-teams-updated-subscriptions_sisense" {
  name                = "sapience-admin-teams-updated-subscriptions_sisense"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-teams-updated.name
  
  max_delivery_count  = 10
  #auto_delete_on_idle = 10
  requires_session = false

}

resource "azurerm_servicebus_topic" "sapience-admin-teams-deleted" {
  name                = "sapience-admin-teams-deleted"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name

  enable_partitioning = false

}

resource "azurerm_servicebus_topic_authorization_rule" "sapience-admin-teams-deleted-publish" {
  name                = "Publish"
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-teams-deleted.name
  resource_group_name = var.resource_group_name
  listen              = false
  send                = true
  manage              = false
}

resource "azurerm_servicebus_topic_authorization_rule" "sapience-admin-teams-deleted-subscribe" {
  name                = "Subscribe"
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-teams-deleted.name
  resource_group_name = var.resource_group_name
  listen              = true
  send                = false
  manage              = false
}

resource "azurerm_servicebus_topic_authorization_rule" "sapience-admin-teams-deleted-full" {
  name                = "Full"
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-teams-deleted.name
  resource_group_name = var.resource_group_name
  listen              = true
  send                = true
  manage              = true
}

resource "azurerm_servicebus_subscription" "sapience-admin-teams-deleted-subscriptions_auth0" {
  name                = "sapience-admin-teams-deleted-subscriptions_auth0"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-teams-deleted.name
  
  max_delivery_count  = 10
  #auto_delete_on_idle = 10
  requires_session = false

}

resource "azurerm_servicebus_subscription" "sapience-admin-teams-deleted-subscriptions_sisense" {
  name                = "sapience-admin-teams-deleted-subscriptions_sisense"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-teams-deleted.name
  
  max_delivery_count  = 10
  #auto_delete_on_idle = 10
  requires_session = false

}

resource "azurerm_servicebus_topic" "sapience-admin-users-deactivated" {
  name                = "sapience-admin-users-deactivated"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name

  enable_partitioning = false

}

resource "azurerm_servicebus_topic_authorization_rule" "sapience-admin-users-deactivated-publish" {
  name                = "Publish"
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-users-deactivated.name
  resource_group_name = var.resource_group_name
  listen              = false
  send                = true
  manage              = false
}

resource "azurerm_servicebus_topic_authorization_rule" "sapience-admin-users-deactivated-subscribe" {
  name                = "Subscribe"
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-users-deactivated.name
  resource_group_name = var.resource_group_name
  listen              = true
  send                = false
  manage              = false
}

resource "azurerm_servicebus_topic_authorization_rule" "sapience-admin-users-deactivated-full" {
  name                = "Full"
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-users-deactivated.name
  resource_group_name = var.resource_group_name
  listen              = true
  send                = true
  manage              = true
}

resource "azurerm_servicebus_subscription" "sapience-admin-users-deactivated-sub_auth0" {
  name                = "sapience-admin-users-deactivated-sub_auth0"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-users-deactivated.name
  
  max_delivery_count  = 5
  #auto_delete_on_idle = 10
  requires_session = false

}

resource "azurerm_servicebus_subscription" "sapience-admin-users-deactivated-sub_sisense" {
  name                = "sapience-admin-users-deactivated-sub_sisense"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-users-deactivated.name
  
  max_delivery_count  = 5
  #auto_delete_on_idle = 10
  requires_session = false

}

resource "azurerm_servicebus_subscription" "sapience-admin-users-deactivated-sub_canopy" {
  name                = "sapience-admin-users-deactivated-sub_canopy"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-users-deactivated.name
  
  max_delivery_count  = 5
  #auto_delete_on_idle = 10
  requires_session = false

}

resource "azurerm_servicebus_topic" "sapience-admin-users-activated" {
  name                = "sapience-admin-users-activated"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name

  enable_partitioning = false

}

resource "azurerm_servicebus_topic_authorization_rule" "sapience-admin-users-activated-publish" {
  name                = "Publish"
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-users-activated.name
  resource_group_name = var.resource_group_name
  listen              = false
  send                = true
  manage              = false
}

resource "azurerm_servicebus_topic_authorization_rule" "sapience-admin-users-activated-subscribe" {
  name                = "Subscribe"
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-users-activated.name
  resource_group_name = var.resource_group_name
  listen              = true
  send                = false
  manage              = false
}

resource "azurerm_servicebus_topic_authorization_rule" "sapience-admin-users-activated-full" {
  name                = "Full"
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-users-activated.name
  resource_group_name = var.resource_group_name
  listen              = true
  send                = true
  manage              = true
}

resource "azurerm_servicebus_subscription" "sapience-admin-users-activated-sub_auth0" {
  name                = "sapience-admin-users-activated-sub_auth0"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-users-activated.name
  
  max_delivery_count  = 5
  #auto_delete_on_idle = 10
  requires_session = false

}

resource "azurerm_servicebus_subscription" "sapience-admin-users-activated-sub_sisense" {
  name                = "sapience-admin-users-activated-sub_sisense"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-users-activated.name
  
  max_delivery_count  = 5
  #auto_delete_on_idle = 10
  requires_session = false

}

resource "azurerm_servicebus_subscription" "sapience-admin-users-activated-sub_canopy" {
  name                = "sapience-admin-users-activated-sub_canopy"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-users-activated.name
  
  max_delivery_count  = 5
  #auto_delete_on_idle = 10
  requires_session = false

}

resource "azurerm_servicebus_topic" "sapience-admin-departments-updated" {
  name                = "sapience-admin-departments-updated"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name

  enable_partitioning = false

}

resource "azurerm_servicebus_topic_authorization_rule" "sapience-admin-departments-updated-publish" {
  name                = "Publish"
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-departments-updated.name
  resource_group_name = var.resource_group_name
  listen              = false
  send                = true
  manage              = false
}

resource "azurerm_servicebus_topic_authorization_rule" "sapience-admin-departments-updated-subscribe" {
  name                = "Subscribe"
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-departments-updated.name
  resource_group_name = var.resource_group_name
  listen              = true
  send                = false
  manage              = false
}

resource "azurerm_servicebus_topic_authorization_rule" "sapience-admin-departments-updated-full" {
  name                = "Full"
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-departments-updated.name
  resource_group_name = var.resource_group_name
  listen              = true
  send                = true
  manage              = true
}

resource "azurerm_servicebus_subscription" "sapience-admin-departments-updated-sub_notifications" {
  name                = "sap-admin-departments-updated-sub_notifications"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-departments-updated.name
  
  max_delivery_count  = 5
  #auto_delete_on_idle = 10
  requires_session = false

}

resource "azurerm_servicebus_topic" "sapience-admin-departments-deleted" {
  name                = "sapience-admin-departments-deleted"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name

  enable_partitioning = false

}

resource "azurerm_servicebus_topic_authorization_rule" "sapience-admin-departments-deleted-publish" {
  name                = "Publish"
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-departments-deleted.name
  resource_group_name = var.resource_group_name
  listen              = false
  send                = true
  manage              = false
}

resource "azurerm_servicebus_topic_authorization_rule" "sapience-admin-departments-deleted-subscribe" {
  name                = "Subscribe"
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-departments-deleted.name
  resource_group_name = var.resource_group_name
  listen              = true
  send                = false
  manage              = false
}

resource "azurerm_servicebus_topic_authorization_rule" "sapience-admin-departments-deleted-full" {
  name                = "Full"
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-departments-deleted.name
  resource_group_name = var.resource_group_name
  listen              = true
  send                = true
  manage              = true
}

resource "azurerm_servicebus_subscription" "sapience-admin-departments-deleted-sub_notifications" {
  name                = "sap-admin-departments-deleted-sub_notifications"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-departments-deleted.name
  
  max_delivery_count  = 5
  #auto_delete_on_idle = 10
  requires_session = false

}

resource "azurerm_servicebus_topic" "sapience-admin-activity-updated" {
  name                = "sapience-admin-activity-updated"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name

  enable_partitioning = false

}

resource "azurerm_servicebus_topic_authorization_rule" "sapience-admin-activity-updated-publish" {
  name                = "Publish"
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-activity-updated.name
  resource_group_name = var.resource_group_name
  listen              = false
  send                = true
  manage              = false
}

resource "azurerm_servicebus_topic_authorization_rule" "sapience-admin-activity-updated-subscribe" {
  name                = "Subscribe"
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-activity-updated.name
  resource_group_name = var.resource_group_name
  listen              = true
  send                = false
  manage              = false
}

resource "azurerm_servicebus_topic_authorization_rule" "sapience-admin-activity-updated-full" {
  name                = "Full"
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-activity-updated.name
  resource_group_name = var.resource_group_name
  listen              = true
  send                = true
  manage              = true
}

resource "azurerm_servicebus_subscription" "sapience-admin-activity-updated-sub_notifications" {
  name                = "sapience-admin-activity-updated-sub_notifications"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-activity-updated.name
  
  max_delivery_count  = 5
  #auto_delete_on_idle = 10
  requires_session = false

}

resource "azurerm_servicebus_topic" "sapience-admin-activity-deleted" {
  name                = "sapience-admin-activity-deleted"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name

  enable_partitioning = false

}

resource "azurerm_servicebus_topic_authorization_rule" "sapience-admin-activity-deleted-publish" {
  name                = "Publish"
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-activity-deleted.name
  resource_group_name = var.resource_group_name
  listen              = false
  send                = true
  manage              = false
}

resource "azurerm_servicebus_topic_authorization_rule" "sapience-admin-activity-deleted-subscribe" {
  name                = "Subscribe"
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-activity-deleted.name
  resource_group_name = var.resource_group_name
  listen              = true
  send                = false
  manage              = false
}

resource "azurerm_servicebus_topic_authorization_rule" "sapience-admin-activity-deleted-full" {
  name                = "Full"
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-activity-deleted.name
  resource_group_name = var.resource_group_name
  listen              = true
  send                = true
  manage              = true
}

resource "azurerm_servicebus_subscription" "sapience-admin-activity-deleted-sub_notifications" {
  name                = "sapience-admin-activity-deleted-sub_notifications"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name
  topic_name          = azurerm_servicebus_topic.sapience-admin-activity-deleted.name
  
  max_delivery_count  = 5
  #auto_delete_on_idle = 10
  requires_session = false

}