# MX RECORDS

# OLD DOMAIN
resource "azurerm_dns_mx_record" "sapience_public" {
  name                = "@"
  zone_name           = azurerm_dns_zone.sapience_public.name
  resource_group_name = var.resource_group_name
  ttl                 = 3600

  record {
    preference = 10
    exchange   = "sapience-net.mail.protection.outlook.com"
  }
  tags = {
    Environment = "Production"
  }
}

# NEW DOMAIN
resource "azurerm_dns_mx_record" "sapienceanalytics_public" {
  name                = "@"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name
  ttl                 = 3600

  record {
    preference = 10
    exchange   = "sapienceanalytics-com.mail.protection.outlook.com"
  }
  tags = {
    Environment = "Production"
  }
}

