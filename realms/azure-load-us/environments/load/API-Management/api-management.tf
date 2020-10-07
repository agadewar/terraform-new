resource "azurerm_api_management" "api-management" {
    name                = "sapience-${var.realm}-${var.environment}"
    location            = var.resource_group_location
    resource_group_name = var.resource_group_name
    publisher_name      = "sapience-analytics"
    publisher_email     = "Ashish.Gadewar@sapienceanalytics.com"
  
    policy {
      xml_content = <<XML
      <policies>
          <inbound>
                  <cors allow-credentials="true">
                          <allowed-origins>
                                  <origin>https://sapience-${var.realm}-${var.environment}.developer.azure-api.net</origin>
                          </allowed-origins>
                          <allowed-methods preflight-result-max-age="300">
                                  <method>*</method>
                          </allowed-methods>
                          <allowed-headers>
                                  <header>*</header>
                          </allowed-headers>
                          <expose-headers>
                                  <header>*</header>
                          </expose-headers>
                  </cors>
          </inbound>
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

resource "azurerm_api_management_api" "api-management" {
  name                = "api-management-api"
  resource_group_name = var.resource_group_name
  api_management_name = "sapience-${var.realm}-${var.environment}"
  revision            = "1"
  display_name        = "Example API"
  path                = "example"
  protocols           = ["https"]

  import {
    content_format = "swagger-link-json"
    content_value  = "http://conferenceapi.azurewebsites.net/?format=json"
  }
}