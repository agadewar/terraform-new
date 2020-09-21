output "servicebus_namespace_default_primary_key" {
  description = "The primary key for service bus namespace"
  value       = azurerm_servicebus_namespace.namespace.default_primary_key
}

output "servicebus_namespace_hostname" {
  description = "The hostname for the service bus namespace"
  value       = "${azurerm_servicebus_namespace.namespace.name}.servicebus.windows.net"
}
