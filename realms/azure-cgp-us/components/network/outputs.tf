# VARIABLE
output "realm_network_name" {
  value = azurerm_virtual_network.realm.name
}

output "default_subnet_id" {
  value = "${azurerm_subnet.default.id}"
}