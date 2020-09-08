resource "azurerm_api_management" "api-management" {
    name                = "sapience-${var.realm}-${var.environment}"
    location            = var.resource_group_location
    resource_group_name = var.resource_group_name
    publisher_name      = "sapience-analytics"
    publisher_email     = "Ashish.Gadewar@sapienceanalytics.com"
  
    policy {
      xml_content = <<XML
      <policies>
        <inbound />
        <backend />
        <outbound />
        <on-error />
      </policies>
  XML
  
    }

    sku {
      name     = "Developer"
      capacity = 1
    }
  
  }