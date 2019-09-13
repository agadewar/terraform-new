# TXT RECORDS
resource "azurerm_dns_txt_record" "sapienceanalytics_txt" {
  name                = "@"
  zone_name           = "${azurerm_dns_zone.sapienceanalytics_public.name}"
  resource_group_name = "${var.resource_group_name}" 
  ttl                 = 3600

  record {
    value = "ZOOM_verify_dfZ_gWR7RH6qeRrXntvOpA"
             
  }
  record {
    value = "v=spf1 include: _spf.sendergen.com include: _spf.protection.outlook.com -all"
  }
  record {
    value = "sapienceanalytics.azurewebsites.net"
  }
}
