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
    var.environment_common_tags,
    map(
      "Component", "DNS"
    )
  )}"
}

resource "azurerm_dns_zone" "dns_public" {
  name                = "${var.environment}.sapience.net"
  resource_group_name = "${var.resource_group_name}"
  zone_type           = "Public"
}
