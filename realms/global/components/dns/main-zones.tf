# SERVICE PRINCPAL
resource "azurerm_role_assignment" "dns_zone_contributor_terraform_sandbox" {
  count = length(var.dns_contributor_role_assignment_ids)

  scope                = "${azurerm_dns_zone.sapienceanalytics_public.id}"
  role_definition_name = "DNS Zone Contributor"
  principal_id         = "${var.dns_contributor_role_assignment_ids[count.index]}"
}

# OLD DOMAIN
resource "azurerm_dns_zone" "sapience_public" {
  name                = "sapience.net"
  resource_group_name = "${var.resource_group_name}"  
  zone_type           = "Public"
}

# NEW DOMAIN
resource "azurerm_dns_zone" "sapienceanalytics_public" {
  name                = "sapienceanalytics.com"
  resource_group_name = "${var.resource_group_name}" 
  zone_type           = "Public"
}

# CUSTOMER PORTAL DOMAIN
resource "azurerm_dns_zone" "sapienceinsider_public" {
  name                = "sapienceinsider.com"
  resource_group_name = "${var.resource_group_name}"  
  zone_type           = "Public"
}