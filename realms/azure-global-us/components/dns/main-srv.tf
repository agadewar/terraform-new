# SRV RECORDS

# OLD DOMAIN
resource "azurerm_dns_srv_record" "sapience_sip" {
  name                = "_sip._tls"
  zone_name           = azurerm_dns_zone.sapience_public.name
  resource_group_name = var.resource_group_name
  ttl                 = 3600

  record {
    priority = 100
    weight   = 1
    port     = 443
    target   = "sipdir.online.lync.com"
  }

  tags = {
    Environment = "Production"
  }
}

resource "azurerm_dns_srv_record" "sapience_sipfederationtls" {
  name                = "_sipfederationtls._tcp"
  zone_name           = azurerm_dns_zone.sapience_public.name
  resource_group_name = var.resource_group_name
  ttl                 = 3600

  record {
    priority = 100
    weight   = 1
    port     = 5061
    target   = "sipfed.online.lync.com"
  }

  tags = {
    Environment = "Production"
  }
}

# NEW DOMAIN
resource "azurerm_dns_srv_record" "_sip" {
  name                = "_sip._tls"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name
  ttl                 = 3600

  record {
    priority = 100
    weight   = 1
    port     = 443
    target   = "sipdir.online.lync.com"
  }

  tags = {
    Environment = "Production"
  }
}

resource "azurerm_dns_srv_record" "_sipfederationtls" {
  name                = "_sipfederationtls._tcp"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name
  ttl                 = 3600

  record {
    priority = 100
    weight   = 1
    port     = 5061
    target   = "sipfed.online.lync.com"
  }

  tags = {
    Environment = "Production"
  }
}

