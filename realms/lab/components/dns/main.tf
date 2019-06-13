terraform {
  backend "azurerm" {
    key = "dns.tfstate"
  }
}

provider "azurerm" {
  version = "1.20.0"
  subscription_id = "${var.subscription_id}"
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

resource "azurerm_dns_zone" "dns_public" {
  name                = "${var.realm}.sapience.net"
  resource_group_name = "${var.resource_group_name}"
  zone_type           = "Public"
}

resource "azurerm_dns_cname_record" "api" {
  count = "${var.create_cname_api >= 1 ? 1 : 0}"

  name                = "api"
  zone_name           = "${azurerm_dns_zone.dns_public.name}"
  resource_group_name = "${var.resource_group_name}"
  ttl                 = 300
  record              = "api.${var.realm}.${azurerm_dns_zone.dns_public.name}"
}