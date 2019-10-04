# Required for App Gateway - Backend Pool
output "network_interface_cgp_app_001" {value = azurerm_network_interface.web_app_001.id}

# Required for App Gateway - Backend Pool
output "ip_configuration_cgp_app_001" {value = azurerm_network_interface.web_app_001.ip_configuration}