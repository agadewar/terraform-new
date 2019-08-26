output "realm_network_name" {
  value = azurerm_virtual_network.realm.name
}

output "default_subnet_id" {
  value = "${azurerm_subnet.default.id}"
}

output "dev-default_subnet_id" {
  value = "${azurerm_subnet.dev-default.id}"
}

output "dev-application_subnet_id" {
  value = "${azurerm_subnet.dev-application.id}"
}

output "dev-data_subnet_id" {
  value = "${azurerm_subnet.dev-data.id}"
}

# output "qa-default_subnet_id" {
#   value = "${azurerm_subnet.qa-default.id}"
# }

# output "qa-application_subnet_id" {
#   value = "${azurerm_subnet.qa-application.id}"
# }

# output "qa-data_subnet_id" {
#   value = "${azurerm_subnet.qa-data.id}"
# }

output "aks-pool04_subnet_id" {
  value = "${azurerm_subnet.aks-pool04.id}"
}

output "aks-pool03_subnet_id" {
  value = "${azurerm_subnet.aks-pool03.id}"
}

output "aks-pool02_subnet_id" {
  value = "${azurerm_subnet.aks-pool02.id}"
}

output "aks-pool01_subnet_id" {
  value = "${azurerm_subnet.aks-pool01.id}"
}
