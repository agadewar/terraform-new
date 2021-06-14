output "realm_network_name" {
  value = azurerm_virtual_network.realm.name
}

output "realm_network_id" {
  value = azurerm_virtual_network.realm.id
}

output "default_subnet_id" {
  value = "${azurerm_subnet.default.id}"
}

output "aks-pool_subnet_id" {
  value = "${azurerm_subnet.aks-pool.id}"
}

output "aks_eastus_sisense_subnet_id" {
  value = azurerm_subnet.aks_eastus_sisense.id
}

output "aks_eastus_sisense_netapp" {
  value = azurerm_subnet.aks_eastus_sisense_netapp.id
}

output "aks-pool01_subnet_id" {
  value = "${azurerm_subnet.aks-pool01.id}"
}

/* output "aks-pool02_subnet_id" {
  value = "${azurerm_subnet.aks-pool02.id}"
}

output "aks-pool03_subnet_id" {
  value = "${azurerm_subnet.aks-pool03.id}"
}

output "aks-pool04_subnet_id" {
  value = "${azurerm_subnet.aks-pool04.id}"
} */

