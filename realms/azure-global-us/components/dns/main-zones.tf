# OLD DOMAIN
resource "azurerm_dns_zone" "sapience_public" {
  name                = "sapience.net"
  resource_group_name = var.resource_group_name
  zone_type           = "Public"
}

# NEW DOMAIN
resource "azurerm_dns_zone" "sapienceanalytics_public" {
  name                = "sapienceanalytics.com"
  resource_group_name = var.resource_group_name
  zone_type           = "Public"
}

# CUSTOMER PORTAL DOMAIN
resource "azurerm_dns_zone" "sapienceinsider_public" {
  name                = "sapienceinsider.com"
  resource_group_name = var.resource_group_name
  zone_type           = "Public"
}

resource "azurerm_dns_zone" "sapienceu_public" {
  name                = "sapienceu.com"
  resource_group_name = var.resource_group_name
  zone_type           = "Public"
}

