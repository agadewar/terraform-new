output "realm_network_name" {
  value = azurerm_virtual_network.realm.name
}

output "aks-pool01_subnet_id" {
  value = azurerm_subnet.aks-pool01.id
}

output "aks-pool02_subnet_id" {
  value = azurerm_subnet.aks-pool02.id
}

output "aks-pool03_subnet_id" {
  value = azurerm_subnet.aks-pool03.id
}

output "aks-pool04_subnet_id" {
  value = azurerm_subnet.aks-pool04.id
}

output "default_subnet_id" {
  value = azurerm_subnet.default.id
}

output "prod-default_subnet_id" {
  value = azurerm_subnet.prod-default.id
}

output "prod-application_subnet_id" {
  value = azurerm_subnet.prod-application.id
}

output "prod-data_subnet_id" {
  value = azurerm_subnet.prod-data.id
}

output "demo-default_subnet_id" {
  value = azurerm_subnet.demo-default.id
}

output "demo-application_subnet_id" {
  value = azurerm_subnet.demo-application.id
}

output "demo-data_subnet_id" {
  value = azurerm_subnet.demo-data.id
}

