# output "aks_egress_ip_address" {
#   value = data.terraform_remote_state.kubernetes_namespace.outputs.aks_egress_ip_address
# }

output "canopy_hierarchy_cosmos_password" {
  description = "Cosmos password for Canopy Hierarchy"
  value       = azurerm_cosmosdb_account.sapience_canopy_hierarchy.primary_master_key
}

output "canopy_settings_mongodb_cosmos_password" {
  description = "Cosmos password for Canopy Settings MongoDB"
  value       = azurerm_cosmosdb_account.canopy_settings_mongodb.primary_master_key
}

#output "lab_us_qa_alerts_cosmos_password" {
#  description = "Cosmos password for Sapience App Alerts"
#  value       = azurerm_cosmosdb_account.lab_us_qa_alerts.primary_master_key
#}

output "lab_us_qa_dashboard_cosmos_password" {
  description = "Cosmos password for Sapience App Dashboard"
  value       = azurerm_cosmosdb_account.lab_us_qa.primary_master_key
}