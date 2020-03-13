# TXT RECORDS
resource "azurerm_dns_txt_record" "sapienceanalytics_txt" {
  name                = "@"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name
  ttl                 = 3600

  record {
    value = "ZOOM_verify_dfZ_gWR7RH6qeRrXntvOpA"
  }

  record {
    value = "v=spf1 include:spf.protection.outlook.com include: _spf.sendergen.com -all"
  }

  record {
    value = "sapienceanalytics.azurewebsites.net"
  } 
}

resource "azurerm_dns_txt_record" "sapienceanalytics_smtpapi_txt" {
  name                = "smtpapi._domainkey"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name
  ttl                 = 3600

  record {
    value = "k=rsa; t=s; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDPtW5iwpXVPiH5FzJ7Nrl8USzuY9zqqzjE0D1r04xDN6qwziDnmgcFNNfMewVKN2D1O+2J9N14hRprzByFwfQW76yojh54Xu3uSbQ3JP0A7k8o8GutRF8zbFUA8n0ZH2y0cIEjMliXY4W4LwPA7m4q0ObmvSjhd63O9d8z1XkUBwIDAQAB"
  }
}

