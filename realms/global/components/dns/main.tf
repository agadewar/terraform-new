terraform {
  backend "azurerm" {
    key = "dns.tfstate"
  }
}

provider "azurerm" {
  version = "1.31.0"
  
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.service_principal_app_id}"
  client_secret   = "${var.service_principal_password}"
  tenant_id       = "${var.service_principal_tenant}"
}

locals {
  resource_group_name = "${var.resource_group_name}"

  common_tags = "${merge(
    var.realm_common_tags,
    map(
      "Component", "DNS"
    )
  )}"
}

resource "azurerm_role_assignment" "dns_zone_contributor_terraform_sandbox" {
  count = length(var.dns_contributor_role_assignment_ids)

  scope                = "${azurerm_dns_zone.sapienceanalytics_public.id}"
  role_definition_name = "DNS Zone Contributor"
  principal_id         = "${var.dns_contributor_role_assignment_ids[count.index]}"
}

resource "azurerm_dns_zone" "sapienceanalytics_public" {
  name                = "sapienceanalytics.com"
  resource_group_name = "${var.resource_group_name}" 
  zone_type           = "Public"
}

resource "azurerm_dns_zone" "sapienceinsider_public" {
  name                = "sapienceinsider.com"
  resource_group_name = "${var.resource_group_name}"  
  zone_type           = "Public"
}

resource "azurerm_dns_a_record" "sapienceanalytics_public" {
  name                = "@"
  zone_name           = "${azurerm_dns_zone.sapienceanalytics_public.name}"
  resource_group_name = "${var.resource_group_name}"  # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  records             = ["52.168.125.188"]
}

resource "azurerm_dns_txt_record" "sapience" {
  name                = "@"
  zone_name           = "${azurerm_dns_zone.sapienceanalytics_public.name}"
  resource_group_name = "${var.resource_group_name}" 
  ttl                 = 300

  record {
    value = "sapienceanalytics.azurewebsites.net"
  }
}

resource "azurerm_dns_cname_record" "api_dev" {
  name                = "api.dev"
  zone_name           = "${azurerm_dns_zone.sapienceanalytics_public.name}"
  resource_group_name = "${var.resource_group_name}"   # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "api.dev.lab.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "jenkins" {
  name                = "jenkins"
  zone_name           = "${azurerm_dns_zone.sapienceanalytics_public.name}"
  resource_group_name = "${var.resource_group_name}"   # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "jenkins.global.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "portal_dev" {
  name                = "portal.dev"
  zone_name           = "${azurerm_dns_zone.sapienceanalytics_public.name}"
  resource_group_name = "${var.resource_group_name}"   # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "portal.dev.lab.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "spinnaker" {
  name                = "spinnaker"
  zone_name           = "${azurerm_dns_zone.sapienceanalytics_public.name}"
  resource_group_name = "${var.resource_group_name}"   # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "spinnaker.global.sapienceanalytics.com"
}
