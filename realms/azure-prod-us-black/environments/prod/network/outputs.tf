output "env-default_subnet_id" {
  value = azurerm_subnet.env-default.id
}

output "env-application_subnet_id" {
  value = azurerm_subnet.env-application.id
}

output "env-data_subnet_id" {
  value = azurerm_subnet.env-data.id
}
