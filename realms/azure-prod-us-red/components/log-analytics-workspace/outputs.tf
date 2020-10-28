output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.log_analytics_workspace.id
}

output "log_analytics_workspace_primary_shared_key" {
  value = azurerm_log_analytics_workspace.log_analytics_workspace.primary_shared_key
}

output "log_analytics_workspace_secondary_shared_key" {
  value = azurerm_log_analytics_workspace.log_analytics_workspace.secondary_shared_key
}

output "log_analytics_workspace_workspace_id" {
  value = azurerm_log_analytics_workspace.log_analytics_workspace.workspace_id
}

output "log_analytics_workspace_portal_url" {
  value = azurerm_log_analytics_workspace.log_analytics_workspace.portal_url
}