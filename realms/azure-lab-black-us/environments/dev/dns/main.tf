terraform {
  backend "azurerm" {
    key = "black/dns.tfstate"
  }
}

provider "azurerm" {
  version         = "1.31.0"
  
  subscription_id = var.global_subscription_id
  client_id       = var.service_principal_app_id
  client_secret   = var.service_principal_password
  tenant_id       = var.service_principal_tenant
}

data "terraform_remote_state" "ingress_controller" {
  backend = "azurerm"
  config = {
    access_key           = var.realm_backend_access_key
    storage_account_name = var.realm_backend_storage_account_name
	  container_name       = var.realm_backend_container_name
    key                  = "black/ingress-controller.tfstate"
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

// resource "azurerm_dns_cname_record" "portal" {
//   // depends_on = [ azurerm_dns_a_record.portal_black ]
//   name                = "portal.${var.environment}.${var.dns_realm}.${var.region}.${var.cloud}"
//   zone_name           = "sapienceanalytics.com"
//   resource_group_name = "global-us"   # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
//   ttl                 = 300
//   record              = azurerm_dns_a_record.portal_black.name
// }

resource "azurerm_dns_a_record" "portal_black" {
  name                = "portal.${var.environment}.${var.dns_realm}-black.${var.region}.${var.cloud}"
  zone_name           = "sapienceanalytics.com"
  resource_group_name = "global-us"
  ttl                 = 300
  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibilty in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  records = [data.terraform_remote_state.ingress_controller.outputs.nginx_ingress_controller_ip]
}

// resource "azurerm_dns_cname_record" "api" {
//   // depends_on = [ azurerm_dns_a_record.api_black ]
//   name                = "api.${var.environment}.${var.dns_realm}.${var.region}.${var.cloud}"
//   zone_name           = "sapienceanalytics.com"
//   resource_group_name = "global-us"   # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
//   ttl                 = 300
//   record              = azurerm_dns_a_record.api_black.name
// }

resource "azurerm_dns_a_record" "kubernetes_black" {
  name                = "kubernetes.${var.environment}.${var.dns_realm}-black.${var.region}.${var.cloud}"
  zone_name           = "sapienceanalytics.com"
  resource_group_name = "global-us"
  ttl                 = 30
  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibilty in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  records = [data.terraform_remote_state.ingress_controller.outputs.nginx_ingress_controller_ip]
}

resource "azurerm_dns_a_record" "api_black" {
  name                = "api.${var.environment}.${var.dns_realm}-black.${var.region}.${var.cloud}"
  zone_name           = "sapienceanalytics.com"
  resource_group_name = "global-us"
  ttl                 = 30
  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibilty in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  records = [data.terraform_remote_state.ingress_controller.outputs.nginx_ingress_controller_ip]
}

resource "azurerm_dns_a_record" "storybook_black" {
  name                = "storybook.${var.environment}.${var.dns_realm}-black.${var.region}.${var.cloud}"
  zone_name           = "sapienceanalytics.com"
  resource_group_name = "global-us"
  ttl                 = 300
  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibilty in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  records = [data.terraform_remote_state.ingress_controller.outputs.nginx_ingress_controller_ip]
}

resource "azurerm_dns_cname_record" "storybook" {
     depends_on = [ azurerm_dns_a_record.storybook_black ]
     name                = "storybook.${var.environment}.${var.dns_realm}.${var.region}.${var.cloud}"
     zone_name           = "sapienceanalytics.com"
     resource_group_name = "global-us"   # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
     ttl                 = 300
     record              = "storybook.dev.lab-black.us.azure.sapienceanalytics.com"
 }

