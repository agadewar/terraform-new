terraform {
  backend "azurerm" {
    key = "dns.tfstate"
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
    key                  = "ingress-controller.tfstate"
  }
}

data "terraform_remote_state" "vm" {
  backend = "azurerm"
  config = {
    access_key           = var.env_backend_access_key
    storage_account_name = var.env_backend_storage_account_name
    container_name       = var.env_backend_container_name
    key                  = "vm.tfstate"
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

/* resource "azurerm_dns_a_record" "portal" {
  name                = "portal.${var.environment}.${var.dns_realm}.${var.region}.${var.cloud}"
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
} */

resource "azurerm_dns_a_record" "app" {
  name                = "app.${var.environment}.${var.dns_realm}.${var.region}.${var.cloud}"
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

resource "azurerm_dns_a_record" "manage" {
  name                = "manage.${var.environment}.${var.dns_realm}.${var.region}.${var.cloud}"
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

resource "azurerm_dns_a_record" "help" {
  name                = "help.${var.environment}.${var.dns_realm}.${var.region}.${var.cloud}"
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

resource "azurerm_dns_a_record" "api" {
  name                = "api.${var.environment}.${var.dns_realm}.${var.region}.${var.cloud}"
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

resource "azurerm_dns_a_record" "sisense_build" {
  name                = "sisense-build.${var.environment}.${var.dns_realm}.${var.region}.${var.cloud}"
  zone_name           = "sapienceanalytics.com"
  resource_group_name = "global-us"
  ttl                 = 300
  records = [data.terraform_remote_state.vm.outputs.public_ip_sisense_build_001]
}

resource "azurerm_dns_a_record" "sisense_appquery" {
  name                = "sisense.${var.environment}.${var.dns_realm}.${var.region}.${var.cloud}"
  zone_name           = "sapienceanalytics.com"
  resource_group_name = "global-us"
  ttl                 = 300
  records = ["40.90.251.194"]
}

resource "azurerm_dns_a_record" "canopy" {
  name                = "canopy.${var.environment}.${var.dns_realm}.${var.region}.${var.cloud}"
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

resource "azurerm_dns_a_record" "canopyv3" {
  name                = "canopyv3.${var.environment}.${var.dns_realm}.${var.region}.${var.cloud}"
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
