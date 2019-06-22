output "zone_name" {
  value = "${azurerm_dns_zone.dns_public.name}"
}

output "sapienceanalytics_public_zone_name" {
  value = "${azurerm_dns_zone.sapienceanalytics_public.name}"
}