resource "azurerm_resource_group" "default" {
  name     = "${var.environment}-${var.location}"
  location = var.location
}