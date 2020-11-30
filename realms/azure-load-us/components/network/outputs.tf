output "realm_network_name" {
  value = azurerm_virtual_network.realm.name
}

output "realm_network_id" {
  value = azurerm_virtual_network.realm.id
}

output "default_subnet_id" {
  value = "${azurerm_subnet.default.id}"
}

output "aks_eastus_sisense_subnet_id" {
  value = "${azurerm_subnet.aks_eastus_sisense.id}"
}

output "netapp_subnet_id" {
  value = "${azurerm_subnet.netapp.id}"
}

# output "demo-default_subnet_id" {
#   value = "${azurerm_subnet.demo-default.id}"
# }

# output "demo-application_subnet_id" {
#   value = "${azurerm_subnet.demo-application.id}"
# }

# output "demo-data_subnet_id" {
#   value = "${azurerm_subnet.demo-data.id}"
# }

output "aks-pool_subnet_id" {
  value = "${azurerm_subnet.aks-pool.id}"
}

output "aks-pool2_subnet_id" {
  value = "${azurerm_subnet.aks-pool2.id}"
}
