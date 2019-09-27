/* output "public_ip_sapience_cgp_001" {
  value = azurerm_public_ip.sapience_cgp_001.ip_address
} */

# Required for App Gateway - Backend Pool
output "network_interface_sapience_cgp_001" {
  value = azurerm_network_interface.sapience_cgp_001.id
}

# Required for App Gateway - Backend Pool
output "ip_configuration_sapience_cgp_001" {
  value = azurerm_network_interface.sapience_cgp_001.ip_configuration
}