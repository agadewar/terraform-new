terraform {
  backend "azurerm" {
    key = "dns.tfstate"
  }
}

provider "azurerm" {
  version = "1.20.0"
  subscription_id = "${var.subscription_id}"
}

data "terraform_remote_state" "dns" {
  backend = "azurerm"
  config {
    access_key           = "${var.backend_access_key}"
    storage_account_name = "${var.backend_storage_account_name}"
	  container_name       = "realm-${var.realm}"
    key                  = "dns.tfstate"
  }
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

# resource "azurerm_dns_a_record" "portal" {
#   name                = "portal.${var.environment}"
#   zone_name           = "${data.terraform_remote_state.dns.zone_name}"
#   resource_group_name = "${var.resource_group_name}"
#   ttl                 = 300
#   records             = [ "${var.portal_ip}" ]
# }
