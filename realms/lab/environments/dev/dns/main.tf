terraform {
  backend "azurerm" {
    key = "dns.tfstate"
  }
}

provider "azurerm" {
  version = "1.20.0"
  subscription_id = "${var.subscription_id}"
}

data "terraform_remote_state" "ingress_controller" {
  backend = "azurerm"
  config {
    access_key           = "${var.backend_access_key}"
    storage_account_name = "${var.backend_storage_account_name}"
	  container_name       = "realm-${var.realm}"
    key                  = "ingress-controller.tfstate"
  }
}

# locals {
#   resource_group_name = "${var.resource_group_name}"

#   common_tags = "${merge(
#     var.realm_common_tags,
#     map(
#       "Component", "DNS"
#     )
#   )}"
# }

resource "azurerm_dns_a_record" "portal" {
  name                = "portal.${var.environment}.${var.realm}"
  zone_name           = "sapienceanalytics.com"
  resource_group_name = "Global"
  ttl                 = 300
  records             = [ "${data.terraform_remote_state.ingress_controller.nginx_ingress_controller_ip}" ]
}
